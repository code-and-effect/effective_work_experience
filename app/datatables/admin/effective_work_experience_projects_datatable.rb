module Admin
  class EffectiveWorkExperienceProjectsDatatable < Effective::Datatable
    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :user, label: 'Intern'
      col :start_on
      col :end_on
      col :name
      col :description

      actions_col
    end

    collection do
      Effective::WorkExperienceProject.deep.all
    end

  end
end
