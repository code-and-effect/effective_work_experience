# My work experience projects
class EffectiveWorkExperienceProjectsDatatable < Effective::Datatable
  datatable do
    order :start_on

    col :updated_at, visible: false
    col :created_at, visible: false
    col :id, visible: false

    col :start_on
    col :end_on

    col :name
    col :description

    unless attributes[:skip_actions]
      actions_col
    end
  end

  collection do
    scope = Effective::WorkExperienceProject.deep.all
    scope = scope.where(user_id: attributes[:user_id], user_type: attributes[:user_type]) if attributes[:user_id].present?

    if work_experience_summary.present?
      scope = scope.during(work_experience_summary.months)
    end

    scope
  end

  def work_experience_summary
    @work_experience_summary ||= if attributes[:work_experience_summary_id].present?
      EffectiveWorkExperience.WorkExperienceSummary.find_by_id(attributes[:work_experience_summary_id])
    end
  end

end
