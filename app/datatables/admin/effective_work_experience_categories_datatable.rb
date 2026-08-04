module Admin
  class EffectiveWorkExperienceCategoriesDatatable < Effective::Datatable
    datatable do
      order :position

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      reorder :position
      col :title
      col :minimum_hours

      actions_col
    end

    collection do
      Effective::WorkExperienceCategory.deep.all
    end

  end
end
