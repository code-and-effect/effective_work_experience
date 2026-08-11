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
      reviewed: 'Reviewed'
    )

    # The mentor review step
    attr_accessor :approve_work_experience_summary

    # Set to true when importing historic data. Skips sending emails.
    attr_accessor :importing

    effective_resource do
      start_on              :date
      end_on                :date

      total_hours           :decimal    # The total number of hours worked this period

      recommendation        :string
      comments              :text       # Private rolling comments displayed to the mentor

      # Acts as Statused
      status                :string
      status_steps          :text

      submitted_at          :datetime
      reviewed_at           :datetime

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
    scope :done, -> { where(status: [:submitted, :reviewed]) }

    before_validation do
      # Only assign from the user when they have the association. Otherwise leave whatever was assigned.
      assign_attributes(mentor: user.work_experience_mentor) if user.respond_to?(:work_experience_mentor)
      assign_attributes(supervisor: user.supervisor) if user.respond_to?(:supervisor)
    end

    before_validation do
      # The admin forms assign the mentor and supervisor id without the polymorphic type
      assign_attributes(mentor_type: (mentor_type.presence || user&.class&.name)) if mentor_id.present?
      assign_attributes(supervisor_type: (supervisor_type.presence || user&.class&.name)) if supervisor_id.present?

      assign_attributes(mentor_type: nil) if mentor_id.blank?
      assign_attributes(supervisor_type: nil) if supervisor_id.blank?
    end

    before_validation do
      assign_attributes(start_on: start_on&.beginning_of_quarter, end_on: start_on&.end_of_quarter)
      assign_attributes(total_hours: calculate_total_hours)
    end

    before_validation do
      assign_attributes(recommendation: recommendations.first) if approve_work_experience_summary
    end

    validates :start_on, presence: true, uniqueness: { scope: [:user_id, :user_type] }
    validates :end_on, presence: true
    validates :total_hours, numericality: { greater_than_or_equal_to: 0.0, allow_blank: true }

    validate(if: -> { user.present? }) do
      errors.add(:user, 'must have a mentor') unless mentor_present?
    end

    validate(if: -> { start_on.present? && end_on.present? }) do
      errors.add(:end_on, 'must be after start date') unless end_on > start_on
      errors.add(:end_on, "must be #{summary_months} months after start date") unless (end_on.month - start_on.month) == (summary_months - 1)
    end

    with_options(if: -> { current_step == :review }) do
      validates :approve_work_experience_summary, acceptance: true
      validates :recommendation, presence: true
    end

    def can_visit_step?(current_step)
      return false if current_user == user && intern_steps.exclude?(current_step)
      return false if current_user == mentor && mentor_steps.exclude?(current_step)

      # Once submitted, the intern cannot go back and submit again
      if was_submitted?
        return false if [:start, :records, :projects, :submit].include?(current_step)
      end

      # Once reviewed, the mentor can go back and review again
      if was_reviewed?
        return [:review, :reviewed].include?(current_step)
      end

      can_revisit_completed_steps(current_step)
    end

  end

  def to_s
    start_on&.strftime('%B %Y') || model_name.human
  end

  # The intern completes the first half of the wizard, the mentor completes the second half
  def intern_steps
    [:start, :records, :projects, :submit, :submitted, :reviewed]
  end

  def mentor_steps
    [:submitted, :review, :reviewed]
  end

  def recommendations
    Array(EffectiveWorkExperience.recommendations)
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


  def total_hours_to_date
    user.work_experience_total_hours_to_date(month: end_on)
  end

  def status_label
    (status_was || status).to_s.gsub('_', ' ').titleize
  end

  def summary
    case status_was
    when 'draft'
      "Work experience summary has not yet been submitted."
    when 'submitted'
      "Work experience summary has been submitted."
    when 'reviewed'
      "Work experience summary has been reviewed."
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
    raise('already submitted') if was_submitted?

    wizard_steps[:submit] ||= Time.zone.now
    wizard_steps[:submitted] = Time.zone.now

    if mentor.present? && !importing
      after_commit { EffectiveWorkExperience.mailer_class.work_experience_summary_submitted(self).deliver }
    end

    work_experience_records.reject(&:was_submitted?).each { |work_experience_record| work_experience_record.submitted! }
    submitted!

    # Auto review summaries for interns without a mentor user
    review! if mentor.blank?

    true
  end

  def review!
    wizard_steps[:review] ||= Time.zone.now
    wizard_steps[:reviewed] = Time.zone.now

    # If it was previously reviewed, or there is no mentor, we don't want to send an email
    unless was_reviewed? || mentor.blank? || importing
      after_commit { EffectiveWorkExperience.mailer_class.work_experience_summary_reviewed(self).deliver }
    end

    work_experience_records.reject(&:was_reviewed?).each { |work_experience_record| work_experience_record.reviewed! }
    reviewed!
  end

  private

  def calculate_total_hours
    return if user.blank? || start_on.blank? || end_on.blank?
    user.work_experience_records.where(month: months).sum { |work_experience_record| work_experience_record.total_hours.to_f }.round(2)
  end

end
