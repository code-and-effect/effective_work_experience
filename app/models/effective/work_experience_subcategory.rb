# The subcategories of work experience. Interns record their hours against these.
module Effective
  class WorkExperienceSubcategory < ActiveRecord::Base
    self.table_name = (EffectiveWorkExperience.work_experience_subcategories_table_name || :work_experience_subcategories).to_s

    belongs_to :work_experience_category, class_name: 'Effective::WorkExperienceCategory'

    log_changes if respond_to?(:log_changes)
    has_rich_text :body

    effective_resource do
      title                         :string
      minimum_hours                 :integer
      position                      :integer
      work_experience_category_id   :integer

      timestamps
    end

    scope :sorted, -> { order(:position) }
    scope :deep, -> { includes(:rich_text_body, :work_experience_category) }

    validates :title, presence: true, uniqueness: { scope: :work_experience_category_id }
    validates :minimum_hours, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
    validates :position, numericality: { greater_than: 0 }, uniqueness: true

    def to_s
      [position, title].compact.join('. ').presence || model_name.human
    end
  end
end
