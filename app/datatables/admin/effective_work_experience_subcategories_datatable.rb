module Admin
  class EffectiveWorkExperienceSubcategoriesDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :position
      col :work_experience_category, search: { collection: Effective::WorkExperienceCategory.sorted.all }
      col :title
      col :minimum_hours
      col :body

      actions_col
    end

    collection do
      Effective::WorkExperienceSubcategory.deep.all
    end

  end
end
