# My work experience summaries
class EffectiveWorkExperienceSummariesDatatable < Effective::Datatable
  datatable do
    order :created_at

    col :token, visible: false
    col :created_at, visible: false

    col :start_on
    col :end_on, visible: false
    col :period

    col :mentor

    col(:total_hours, label: 'Hours') do |work_experience_summary|
      work_experience_hours_to_s(work_experience_summary.total_hours)
    end

    col(:total_hours_to_date, as: :decimal) do |work_experience_summary|
      work_experience_hours_to_s(work_experience_summary.total_hours_to_date)
    end

    col :status

    col(:submitted_at, label: 'Submitted') do |work_experience_summary|
      work_experience_summary.submitted_at&.strftime('%F') || 'Incomplete'
    end

    col(:reviewed_at, label: 'Reviewed', as: :date) do |work_experience_summary|
      work_experience_summary.reviewed_at&.strftime('%F') || 'Not yet reviewed'
    end

    actions_col(show: false) do |work_experience_summary|
      if work_experience_summary.draft?
        dropdown_link_to('Continue', effective_work_experience.work_experience_summary_build_path(work_experience_summary, work_experience_summary.next_step), 'data-turbolinks' => false)
        dropdown_link_to('Delete', effective_work_experience.work_experience_summary_path(work_experience_summary), 'data-confirm': "Really delete #{work_experience_summary}?", 'data-method': :delete)
      else
        dropdown_link_to('Show', effective_work_experience.work_experience_summary_path(work_experience_summary))
      end
    end
  end

  collection do
    scope = EffectiveWorkExperience.WorkExperienceSummary.deep.all
    scope = scope.where(user_id: attributes[:user_id], user_type: attributes[:user_type]) if attributes[:user_id].present?
    scope
  end

end
