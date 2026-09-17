# Mentor & supervisor dashboard only.
# Work experience summaries assigned to the current user as mentor or supervisor
class EffectiveWorkExperienceSummariesReviewDatatable < Effective::Datatable
  datatable do
    order :created_at

    col :token, visible: false
    col :created_at, visible: false

    col(:submitted_at, label: 'Submitted') do |work_experience_summary|
      work_experience_summary.submitted_at&.strftime('%F') || 'Incomplete'
    end

    col :user, label: 'Intern'
    col :period
    col :start_on, visible: false
    col :end_on, visible: false

    col(:total_hours) do |work_experience_summary|
      work_experience_hours_to_s(work_experience_summary.total_hours)
    end

    col :status

    col :mentor_recommendation, search: :string, visible: false
    col :mentor_comments, visible: false

    col :supervisor_recommendation, search: :string, visible: false
    col :supervisor_comments, visible: false

    actions_col(show: false) do |work_experience_summary|
      if !EffectiveResources.authorized?(self, :update, work_experience_summary)
        dropdown_link_to('Show', effective_work_experience.work_experience_summary_path(work_experience_summary))
      elsif work_experience_summary.submitted?
        dropdown_link_to('Start Review', effective_work_experience.work_experience_summary_build_path(work_experience_summary, work_experience_summary.next_step), 'data-turbolinks' => false, 'data-turbo' => false)
      else
        dropdown_link_to('Show', effective_work_experience.work_experience_summary_path(work_experience_summary))
        dropdown_link_to('Review again', effective_work_experience.work_experience_summary_build_path(work_experience_summary, :review), 'data-turbolinks' => false, 'data-turbo' => false)
      end
    end
  end

  collection do
    scope = EffectiveWorkExperience.WorkExperienceSummary.deep.where.not(status: :draft)
    scope.where(mentor: current_user).or(scope.where(supervisor: current_user))
  end

end
