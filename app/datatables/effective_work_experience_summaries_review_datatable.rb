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

    col :user, label: work_experience_intern_label
    col :period
    col :start_on, visible: false
    col :end_on, visible: false

    col(:total_hours) do |work_experience_summary|
      work_experience_hours_to_s(work_experience_summary.total_hours)
    end

    col :status

    col :mentor_recommendation, label: "#{work_experience_mentor_label} Recommendation", search: :string, visible: false
    col :mentor_comments, label: "#{work_experience_mentor_label} Comments", visible: false

    if EffectiveWorkExperience.use_supervisor?
      col :supervisor_recommendation, label: "#{work_experience_supervisor_label} Recommendation", search: :string, visible: false
      col :supervisor_comments, label: "#{work_experience_supervisor_label} Comments", visible: false
    end

    actions_col(show: false) do |work_experience_summary|
      if !EffectiveResources.authorized?(self, :update, work_experience_summary)
        dropdown_link_to('Show', effective_work_experience.work_experience_summary_path(work_experience_summary))
      elsif !work_experience_summary.reviewed_by?(current_user)
        dropdown_link_to('Start Review', effective_work_experience.work_experience_summary_build_path(work_experience_summary, work_experience_summary.next_step), 'data-turbolinks' => false, 'data-turbo' => false)
      else
        dropdown_link_to('Show', effective_work_experience.work_experience_summary_path(work_experience_summary))
        step = (EffectiveWorkExperience.use_supervisor? && work_experience_summary.supervisor == current_user && work_experience_summary.mentor != current_user) ? :review_two : :review
        dropdown_link_to('Review again', effective_work_experience.work_experience_summary_build_path(work_experience_summary, step), 'data-turbolinks' => false, 'data-turbo' => false)
      end
    end
  end

  collection do
    scope = EffectiveWorkExperience.WorkExperienceSummary.deep.where.not(status: :draft)
    scope.where(mentor: current_user).or(scope.where(supervisor: current_user))
  end

end
