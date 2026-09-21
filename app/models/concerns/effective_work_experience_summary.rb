# frozen_string_literal: true

# EffectiveWorkExperienceSummary
#
# Mark your model with effective_work_experience_summary to get all the includes
#
# The summary of an intern's work experience for one period, usually 3 months.
# Submitted by the intern, and reviewed by their mentor.

module EffectiveWorkExperienceSummary
  extend ActiveSupport::Concern

  module Base
    def effective_work_experience_summary
      include ::EffectiveWorkExperienceSummary
    end
  end

  module ClassMethods
    def effective_work_experience_summary?; true; end
  end

  included do
    # The intern
    belongs_to :user, polymorphic: true

    # The mentor reviews the submitted work experience summary
    belongs_to :mentor, polymorphic: true, optional: true

    # The supervisor is responsible for the intern's day to day work
    belongs_to :supervisor, polymorphic: true, optional: true

    acts_as_tokened

    log_changes(to: :user) if respond_to?(:log_changes)

    acts_as_statused(
      :draft,       # In-progress submission
      :submitted,   # Submitted by intern
      :reviewed     # Reviewed by mentor
    )

    acts_as_wizard(
      # Intern steps
      start: 'Start',
      records: 'Work Experience Hours',
      projects: 'Work Experience Projects',
      submit: 'Submit',

      # Intern and mentor step
      submitted: 'Submitted',

      # Mentor steps
      review: 'Mentor Review',
      reviewed: 'Reviewed',

      # Supervisor steps
      review_two: 'Supervisor Review',
      reviewed_two: 'Reviewed'
    )

    # Set to true when importing historic data. Skips sending emails.
    attr_accessor :importing

    effective_resource do
      start_on              :date
      end_on                :date

      category              :string

      year                  :integer
      quarter               :integer

      total_hours           :decimal    # The total number of hours worked this period

      # Review Step
      mentor_recommendation     :string
      mentor_comments           :text       # Private rolling comments displayed to the mentor

      # ReviewTwo Step
      supervisor_recommendation :string
      supervisor_comments       :text

      # Acts as Statused
      status                :string
      status_steps          :text

      submitted_at          :datetime
      reviewed_at           :datetime
      approved_at           :datetime
      declined_at           :datetime

      # Acts as Wizard
      wizard_steps          :text, permitted: false

      # Acts as Tokened
      token                 :string

      timestamps
    end

    scope :sorted, -> { order(:start_on) }
    scope :deep, -> { includes(:user, :mentor, :supervisor) }

    scope :in_progress, -> { where(status: :draft) }
    scope :in_progress_for, ->(user) { where(user: user, status: :draft) }
    scope :done, -> { where.not(status: :draft) }

    # Disabled by default. To be implemented by tenant
    scope :needs_reminder, -> { none }
    scope :needs_auto_approval, -> { none }

    before_validation(if: -> { user.present? }) do
      self.mentor ||= user.work_experience_mentor
      self.supervisor ||= user.work_experience_supervisor
      self.category ||= user.current_work_experience_category
    end

    before_validation do
      # The admin forms assign the mentor and supervisor id without the polymorphic type
      assign_attributes(mentor_type: (mentor_type.presence || user&.class&.name)) if mentor_id.present?
      assign_attributes(supervisor_type: (supervisor_type.presence || user&.class&.name)) if supervisor_id.present?

      assign_attributes(mentor_type: nil) if mentor_id.blank?
      assign_attributes(supervisor_type: nil) if supervisor_id.blank?
    end

    before_validation(if: -> { start_on.present? }) do
      assign_attributes(start_on: start_on.beginning_of_quarter, end_on: start_on.end_of_quarter)
      assign_attributes(year: start_on.year, quarter: start_on.quarter)
      assign_attributes(total_hours: calculate_total_hours)
    end

    validates :start_on, presence: true, uniqueness: { scope: [:user_id, :user_type] }
    validates :end_on, presence: true
    validates :total_hours, numericality: { greater_than_or_equal_to: 0.0, allow_blank: true }

    validate(if: -> { user.present? }) do
      errors.add(:user, "must have a #{EffectiveResources.et('effective_work_experience.mentor').downcase}") unless mentor_present?
      if EffectiveWorkExperience.use_supervisor? && supervisor.blank?
        errors.add(:user, "must have a #{EffectiveResources.et('effective_work_experience.supervisor').downcase}")
      end
    end

    validate(if: -> { start_on.present? && end_on.present? }) do
      errors.add(:end_on, 'must be after start date') unless end_on > start_on
      errors.add(:end_on, "must be #{summary_months} months after start date") unless (end_on.month - start_on.month) == (summary_months - 1)
    end

    with_options(if: -> { current_step == :declarations }) do
      validates :declare_truth, acceptance: true
    end

    with_options(if: -> { current_step == :review }) do
      validates :mentor_recommendation, presence: true
    end

    with_options(if: -> { current_step == :review_two }) do
      validates :supervisor_recommendation, presence: true
    end

    def can_visit_step?(step)
      if current_user_intern? && was_submitted?
        return step == :reviewed_two if has_completed_step?(:reviewed_two)
        return step == :reviewed if has_completed_step?(:reviewed)
        return step == :submitted
      end

      if current_user_intern?
        return false unless intern_steps.include?(step)
        return can_revisit_completed_steps(step)
      end

      if current_user_mentor?
        return false unless was_submitted?
        return false unless mentor_steps.include?(step)
        return false if step == :reviewed && !has_completed_step?(:review)
        return true
      end

      if current_user_supervisor?
        return false unless was_submitted?
        return false unless supervisor_steps.include?(step)
        return false if step == :reviewed_two && !has_completed_step?(:review_two)
        return true
      end

      false
    end

  end

  def to_s
    start_on&.strftime('%B %Y') || model_name.human
  end

  # The intern completes the first half of the wizard, the mentor completes the second half
  def intern_steps
    [:start, :records, :projects, :declarations, :submit, :submitted, :reviewed, :reviewed_two]
  end

  def mentor_steps
    [:submitted, :review, :reviewed]
  end

  def supervisor_steps
    [:submitted, :review_two, :reviewed_two]
  end

  def current_user_intern?
    current_user.present? && (user == current_user)
  end

  def current_user_mentor?
    current_user.present? && (mentor == current_user || user.work_experience_mentor == current_user)
  end

  def current_user_supervisor?
    current_user.present? && (supervisor == current_user || user.work_experience_supervisor == current_user)
  end

  def recommendations
    Array(EffectiveWorkExperience.recommendations)
  end

  def reviewed_by?(user)
    return false if user.blank?
    return mentor_recommendation.present? if mentor == user
    return supervisor_recommendation.present? if supervisor == user

    false
  end

  def summary_months
    (EffectiveWorkExperience.summary_months || 3)
  end

  # The first day of each month in this summary period
  def months
    @months ||= start_on.all_quarter.to_a.select { |month| month.day == 1 }
  end

  def period
    return if start_on.blank?
    "#{months.first.strftime('%B %Y')} to #{months.last.strftime('%B %Y')}"
  end

  # An intern with an outside mentor has no mentor user. Their summaries are automatically reviewed.
  def mentor_present?
    mentor.present? || user.try(:work_experience_outside_mentor?).present?
  end

  def mentor_approved?
    mentor_recommendation == Array(EffectiveWorkExperience.recommendations).first
  end

  def mentor_declined?
    mentor_recommendation.present? && mentor_recommendation == recommendations.last
  end

  def supervisor_approved?
    supervisor_recommendation == Array(EffectiveWorkExperience.recommendations).first
  end

  def supervisor_declined?
    supervisor_recommendation.present? && supervisor_recommendation == recommendations.last
  end

  def total_hours_to_date
    user.work_experience_total_hours_to_date(month: end_on)
  end

  def status_label
    (status_was || status).to_s.gsub('_', ' ').titleize
  end

  def summary
    case status_was
    when 'draft'
      "#{EffectiveResources.et(self.class)} has not yet been submitted."
    when 'submitted'
      "#{EffectiveResources.et(self.class)} has been submitted."
    when 'approved'
      "#{EffectiveResources.et(self.class)} has been approved."
    when 'auto_approved'
      "#{EffectiveResources.et(self.class)} has been automatically approved."
    when 'declined'
      "#{EffectiveResources.et(self.class)} has been declined."
    when 'reviewed'
      reviewers = [
        (EffectiveResources.et('effective_work_experience.mentor') if mentor_recommendation.present?),
        (EffectiveResources.et('effective_work_experience.supervisor') if supervisor_recommendation.present?)
      ].compact.join(' and ')

      reviewers.present? ? "#{EffectiveResources.et(self.class)} has been reviewed by #{reviewers}." : "#{EffectiveResources.et(self.class)} has been reviewed."
    else
      raise("unexpected status #{status}")
    end.html_safe
  end

  def work_experience_subcategories
    Effective::WorkExperienceSubcategory.all.sorted
  end

  def work_experience_records
    @work_experience_records ||= user.work_experience_records.where(month: months)
  end

  def work_experience_projects
    @work_experience_projects ||= user.work_experience_projects.during(months)
  end

  def submit!
    raise('submitted status is not supported') unless all_statuses.include?(:submitted)
    raise('already submitted') if was_submitted?

    all_steps_before(:submitted).each { |step| wizard_steps[step] ||= Time.zone.now }
    wizard_steps[:submitted] = Time.zone.now

    unless importing
      after_commit do
        send_email(:work_experience_summary_submitted) if mentor.present?
        send_email(:work_experience_summary_submitted_two) if supervisor.present?
      end
    end

    work_experience_records.reject(&:was_submitted?).each { |work_experience_record| work_experience_record.submitted! }
    submitted!

    # Auto review summaries for interns without a mentor user
    review! if mentor.blank? && supervisor.blank?

    true
  end

  def unsubmit!
    raise('draft status is not supported') unless all_statuses.include?(:draft)
    raise('cannot unsubmit this work experience summary') unless was_submitted?

    work_experience_records.each do |record|
      record.update!(status: :draft, status_steps: {}, submitted_at: nil, reviewed_at: nil)
    end

    update!(
      status: :draft,
      status_steps: {},
      wizard_steps: {},
      submitted_at: nil,
      reviewed_at: nil,
      approved_at: nil,
      declined_at: nil,
      mentor_recommendation: nil,
      supervisor_recommendation: nil
    )
  end

  def review!
    wizard_steps[:review] ||= Time.zone.now
    wizard_steps[:reviewed] = Time.zone.now

    # If it was previously reviewed, or there is no mentor, we don't want to send an email
    unless importing || reviewed_at.present? || mentor.blank? || (all_statuses.include?(:declined) && mentor_declined?)
      after_commit { send_email(:work_experience_summary_reviewed) }
    end

    work_experience_records.reject(&:was_reviewed?).each { |work_experience_record| work_experience_record.reviewed! }

    respond_to?(:reviewed!) ? reviewed! : update!(reviewed_at: Time.zone.now)

    try_approve_or_decline!
    true
  end

  def review_two!
    wizard_steps[:review_two] ||= Time.zone.now
    wizard_steps[:reviewed_two] = Time.zone.now

    # The first review notifies the intern; a decline sends its own email instead.
    unless importing || reviewed_at.present? || supervisor.blank? || (all_statuses.include?(:declined) && supervisor_declined?)
      after_commit { send_email(:work_experience_summary_reviewed_two) }
    end

    work_experience_records.reject(&:was_reviewed?).each { |work_experience_record| work_experience_record.reviewed! }

    respond_to?(:reviewed!) ? reviewed! : update!(reviewed_at: Time.zone.now)

    try_approve_or_decline!
    true
  end

  # The first recommendation approves, the last declines. Other choices remain submitted.
  # Only tenants declaring these optional statuses opt into a final determination.
  def try_approve_or_decline!
    return true unless all_statuses.include?(:approved) && all_statuses.include?(:declined)
    return true unless was_submitted?

    recommendations = [mentor_recommendation]
    recommendations << supervisor_recommendation if EffectiveWorkExperience.use_supervisor?

    # Any recommend decline declines
    if recommendations.any? { |recommendation| recommendation == Array(EffectiveWorkExperience.recommendations).last }
      return decline! unless declined?
    end

    return true unless submitted?

    # Any recommend approve approves
    if recommendations.all? { |recommendation| recommendation == Array(EffectiveWorkExperience.recommendations).first }
      return approve! unless approved?
    end

    # Stay reviewed or submitted
    true
  end

  def approve!
    raise('approved status is not supported') unless all_statuses.include?(:approved)
    approved!
  end

  def auto_approve!
    raise('auto_approved status is not supported') unless all_statuses.include?(:auto_approved)

    return unless submitted?
    return if mentor_declined? || supervisor_declined?

    transaction do
      work_experience_records.reject(&:was_reviewed?).each(&:reviewed!)

      self.reviewed_at ||= Time.zone.now
      try(:reviewed!)

      auto_approved!
    end

    true
  end

  def decline!
    raise('declined status is not supported') unless all_statuses.include?(:declined)
    after_commit { send_email(:work_experience_summary_declined) } unless importing || declined?
    declined!
  end

  def mark_as_submitted!
    raise('submitted status is not supported') unless all_statuses.include?(:submitted)
    raise('already submitted') if submitted?
    submitted!
  end

  def mark_as_approved!
    raise('approved status is not supported') unless all_statuses.include?(:approved)
    raise('already approved') if approved?
    approved!
  end

  def mark_as_declined!
    raise('declined status is not supported') unless all_statuses.include?(:declined)
    raise('already declined') if declined?
    declined!
  end

  private

  def send_email(email)
    EffectiveWorkExperience.send_email(email, self)
  end

  def calculate_total_hours
    return if user.blank? || start_on.blank? || end_on.blank?
    user.work_experience_records.where(month: months).sum { |work_experience_record| work_experience_record.total_hours.to_f }.round(2)
  end

end
