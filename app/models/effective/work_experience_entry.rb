# One row in a monthly work experience record
module Effective
  class WorkExperienceEntry < ActiveRecord::Base
    self.table_name = (EffectiveWorkExperience.work_experience_entries_table_name || :work_experience_entries).to_s

    belongs_to :user, polymorphic: true
    belongs_to :work_experience_record, class_name: 'Effective::WorkExperienceRecord', inverse_of: :work_experience_entries
    belongs_to :work_experience_subcategory, class_name: 'Effective::WorkExperienceSubcategory'

    log_changes(to: :user) if respond_to?(:log_changes)

    effective_resource do
      week_1                  :decimal
      week_2                  :decimal
      week_3                  :decimal
      week_4                  :decimal
      week_5                  :decimal

      timestamps
    end

    before_validation(if: -> { work_experience_record.present? }) do
      assign_attributes(user: work_experience_record.user)
    end

    validates :week_1, numericality: { greater_than_or_equal_to: 0.0, allow_blank: true }
    validates :week_2, numericality: { greater_than_or_equal_to: 0.0, allow_blank: true }
    validates :week_3, numericality: { greater_than_or_equal_to: 0.0, allow_blank: true }
    validates :week_4, numericality: { greater_than_or_equal_to: 0.0, allow_blank: true }
    validates :week_5, numericality: { greater_than_or_equal_to: 0.0, allow_blank: true }

    scope :sorted, -> { order(:id) }
    scope :deep, -> { includes(:user, work_experience_subcategory: :work_experience_category) }

    def to_s
      'work experience entry'
    end

    def hours
      (week_1.to_f + week_2.to_f + week_3.to_f + week_4.to_f + week_5.to_f)
    end
  end
end
