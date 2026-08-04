# A work experience project
module Effective
  class WorkExperienceProject < ActiveRecord::Base
    self.table_name = (EffectiveWorkExperience.work_experience_projects_table_name || :work_experience_projects).to_s

    belongs_to :user, polymorphic: true

    log_changes(to: :user) if respond_to?(:log_changes)

    effective_resource do
      name                  :string
      description           :text

      start_on              :date
      end_on                :date

      timestamps
    end

    scope :sorted, -> { order(:start_on) }
    scope :deep, -> { includes(:user) }

    scope :during, ->(months) {
      where('start_on <= ? AND (end_on IS NULL OR end_on >= ?)', months.last, months.first)
    }

    validates :name, presence: true, uniqueness: { scope: [:user_id, :user_type] }
    validates :start_on, presence: true

    validate(if: -> { start_on.present? && end_on.present? }) do
      errors.add(:end_on, 'must be after the start date') if end_on < start_on
    end

    def to_s
      name.presence || model_name.human
    end
  end
end
