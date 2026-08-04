# The top level grouping of work experience subcategories
module Effective
  class WorkExperienceCategory < ActiveRecord::Base
    self.table_name = (EffectiveWorkExperience.work_experience_categories_table_name || :work_experience_categories).to_s

    log_changes if respond_to?(:log_changes)

    has_many :work_experience_subcategories, -> { order(:position) }, class_name: 'Effective::WorkExperienceSubcategory', inverse_of: :work_experience_category

    effective_resource do
      title           :string
      minimum_hours   :integer
      position        :integer

      timestamps
    end

    scope :sorted, -> { order(:position) }
    scope :deep, -> { all }

    validates :title, presence: true, uniqueness: true
    validates :minimum_hours, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
    validates :position, numericality: { greater_than: 0 }

    def to_s
      title.presence || model_name.human
    end
  end
end
