# The mentor's work experience summaries to review
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

    col :recommendation, search: :string, visible: false
    col :comments, visible: false

    actions_col(show: false) do |work_experience_summary|
      if work_experience_summary.submitted?
        dropdown_link_to('Start Review', effective_work_experience.work_experience_summary_build_path(work_experience_summary, work_experience_summary.next_step), 'data-turbolinks' => false)
      else
        dropdown_link_to('Show', effective_work_experience.work_experience_summary_path(work_experience_summary))
        dropdown_link_to('Review again', effective_work_experience.work_experience_summary_build_path(work_experience_summary, :review), 'data-turbolinks' => false)
      end
    end
  end

  collection do
    scope = EffectiveWorkExperience.WorkExperienceSummary.deep.where.not(status: :draft)
    scope = scope.where(mentor_id: attributes[:mentor_id], mentor_type: attributes[:mentor_type]) if attributes[:mentor_id].present?
    scope
  end

end
