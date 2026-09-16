# An individual work experience activity, assigned to a summary when submitted.
module Effective
  class WorkExperienceActivity < ActiveRecord::Base
    self.table_name = (EffectiveWorkExperience.work_experience_activities_table_name || :work_experience_activities).to_s

    belongs_to :user, polymorphic: true
    belongs_to :work_experience_subcategory, class_name: 'Effective::WorkExperienceSubcategory'
    belongs_to :work_experience_summary, class_name: 'Effective::WorkExperienceSummary', optional: true

    log_changes(to: :user) if respond_to?(:log_changes)

    effective_resource do
      date                        :date
      description                 :text
      hours                       :decimal

      timestamps
    end

    scope :sorted, -> { order(:date, :id) }
    scope :deep, -> { includes(:user, :work_experience_summary, work_experience_subcategory: :work_experience_category) }
    scope :unassigned, -> { where(work_experience_summary_id: nil) }
    scope :during, ->(start_on, end_on) { where(date: start_on..end_on) }

    validates :date, :description, presence: true
    validates :hours, numericality: { greater_than_or_equal_to: 0.0 }

    validate(if: -> { work_experience_summary.present? }) do
      errors.add(:work_experience_summary, 'must belong to the same user') unless work_experience_summary.user == user
    end

    def to_s
      description.presence || model_name.human
    end
  end
end
