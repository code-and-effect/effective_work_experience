# My work experience summaries
class EffectiveWorkExperienceSummariesDatatable < Effective::Datatable
  datatable do
    order :created_at

    col :token, visible: false
    col :created_at, visible: false
    col :user, visible: false

    if EffectiveWorkExperience.hours_log?
      col :start_on, search: work_experience_summary_start_on_collection(), visible: false
      col :end_on, visible: false
      col :period, visible: false
      col :year, search: EffectiveWorkExperience.WorkExperienceSummary.distinct.pluck(:year).compact.sort.reverse
      col :quarter, search: (1..4).to_a
    else
      col :start_on, search: work_experience_summary_start_on_collection()
      col :end_on, visible: false
      col :period
      col :year, search: EffectiveWorkExperience.WorkExperienceSummary.distinct.pluck(:year).compact.sort.reverse, visible: false
      col :quarter, search: (1..4).to_a, visible: false
    end

    col :mentor, label: work_experience_mentor_label, visible: false

    if EffectiveWorkExperience.use_supervisor?
      col :supervisor, label: work_experience_supervisor_label, visible: false
    end

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

    col :reviewed_at, label: 'Reviewed', as: :date, visible: false
    col :approved_at, label: 'Approved', as: :date, visible: false
    col :declined_at, label: 'Declined', as: :date, visible: false

    actions_col(show: false) do |work_experience_summary|
      if work_experience_summary.draft? && EffectiveResources.authorized?(self, :update, work_experience_summary)
        dropdown_link_to('Continue', effective_work_experience.work_experience_summary_build_path(work_experience_summary, work_experience_summary.next_step), 'data-turbolinks' => false, 'data-turbo' => false)
        if EffectiveResources.authorized?(self, :destroy, work_experience_summary)
          dropdown_link_to('Delete', effective_work_experience.work_experience_summary_path(work_experience_summary), 'data-confirm': "Really delete #{work_experience_summary}?", 'data-method': :delete)
        end
      else
        dropdown_link_to('Show', effective_work_experience.work_experience_summary_path(work_experience_summary))
        if EffectiveResources.authorized?(self, :unsubmit, work_experience_summary)
          dropdown_link_to('Unsubmit', effective_work_experience.unsubmit_work_experience_summary_path(work_experience_summary), 'data-method': :post, 'data-confirm': 'Unsubmit this summary and clear its reviews?')
        end
      end
    end
  end

  collection do
    EffectiveWorkExperience.WorkExperienceSummary.deep.all
  end

end
