# A monthly grid or individual hours log record of work experience
module Effective
  class WorkExperienceRecord < ActiveRecord::Base
    self.table_name = (EffectiveWorkExperience.work_experience_records_table_name || :work_experience_records).to_s

    belongs_to :user, polymorphic: true

    # When in Monthly Grid mode only
    has_many :work_experience_entries, -> { order(:id) }, class_name: 'Effective::WorkExperienceEntry', inverse_of: :work_experience_record, dependent: :destroy
    accepts_nested_attributes_for :work_experience_entries, allow_destroy: true

    # When in Hours Log mode only
    belongs_to :work_experience_subcategory, class_name: 'Effective::WorkExperienceSubcategory', optional: true

    log_changes(to: :user) if respond_to?(:log_changes)
    has_many_rich_texts

    acts_as_statused(
      :draft,       # In-progress submission
      :submitted,   # Submitted by intern
      :reviewed     # Reviewed by mentor
    )

    effective_resource do
      month                 :date       # The 1st day of the month of the work experience
      total_hours           :decimal    # The total number of hours worked for the month

      # When in Hours Log mode
      description           :text
      date                  :date

      # There can only be one backdated work experience record
      backdated             :boolean, default: false, permitted: :admin

      # Acts as Statused
      status                :string
      status_steps          :text

      submitted_at          :datetime
      reviewed_at           :datetime

      timestamps
    end

    before_validation(if: -> { EffectiveWorkExperience.monthly_grid? }) do
      assign_attributes(total_hours: work_experience_entries.sum(&:hours).round(2))
    end

    before_validation do
      assign_attributes(month: month&.beginning_of_month)
      assign_attributes(month: nil) if backdated?
    end

    validates :month, presence: true, unless: -> { backdated }
    validates :month, absence: true, if: -> { backdated }
    validates :total_hours, numericality: { greater_than_or_equal_to: 0.0 }

    with_options(if: -> { EffectiveWorkExperience.monthly_grid? }) do
      validates :month, uniqueness: { scope: [:user_id, :user_type] }
    end

    with_options(if: -> { EffectiveWorkExperience.hours_log? }) do
      validates :description, presence: true
      validates :date, presence: true
      validates :work_experience_subcategory, presence: true
    end

    validate(if: -> { month.present? }) do
      errors.add(:month, 'must be the first day of the month') unless month.day == 1
    end

    validate(if: -> { user.present? && month.present? && (new_record? || will_save_change_to_total_hours? || will_save_change_to_month?) }) do
      if user.work_experience_summaries.done.where(start_on: month.beginning_of_quarter).exists?
        errors.add(:month, 'belongs to a submitted work experience summary')
      end
    end

    scope :sorted, -> { order(:month) }
    scope :deep, -> { includes(:user, work_experience_entries: { work_experience_subcategory: :work_experience_category }) }
    scope :during, ->(months) { where(month: months) }

    def to_s
      description.presence || month&.strftime('%B %Y') || model_name.human
    end

    # Find or build
    def work_experience_entry(work_experience_subcategory:)
      entry = work_experience_entries.find { |work_experience_entry| work_experience_entry.work_experience_subcategory_id == work_experience_subcategory.id }
      entry ||= work_experience_entries.build(work_experience_subcategory: work_experience_subcategory)
      entry
    end

    def week_1_total
      work_experience_entries.sum { |work_experience_entry| work_experience_entry.week_1 || 0.0 }.round(2)
    end

    def week_2_total
      work_experience_entries.sum { |work_experience_entry| work_experience_entry.week_2 || 0.0 }.round(2)
    end

    def week_3_total
      work_experience_entries.sum { |work_experience_entry| work_experience_entry.week_3 || 0.0 }.round(2)
    end

    def week_4_total
      work_experience_entries.sum { |work_experience_entry| work_experience_entry.week_4 || 0.0 }.round(2)
    end

    def week_5_total
      work_experience_entries.sum { |work_experience_entry| work_experience_entry.week_5 || 0.0 }.round(2)
    end

    def total_hours_to_date
      user&.work_experience_total_hours_to_date(month: month)
    end
  end
end
