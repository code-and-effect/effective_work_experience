module Admin
  class EffectiveWorkExperienceSummariesDatatable < Effective::Datatable
    filters do
      scope :all
      scope :draft
      scope :submitted
      scope :reviewed
    end

    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :start_on, search: work_experience_summary_start_on_collection()
      col :end_on, visible: false
      col :period
      col :status

      col :user, label: 'Intern'
      col :mentor
      col :supervisor, visible: false

      col(:total_hours) do |work_experience_summary|
        work_experience_hours_to_s(work_experience_summary.total_hours)
      end

      col(:total_hours_to_date, as: :decimal) do |work_experience_summary|
        work_experience_hours_to_s(work_experience_summary.total_hours_to_date)
      end

      col(:submitted_at, label: 'Submitted') do |work_experience_summary|
        work_experience_summary.submitted_at&.strftime('%F')
      end

      col(:reviewed_at, label: 'Reviewed', as: :date) do |work_experience_summary|
        work_experience_summary.reviewed_at&.strftime('%F')
      end

      col :recommendation, visible: false
      col :comments

      col :status_steps, visible: false
      col :wizard_steps, visible: false
      col :token, visible: false

      actions_col
    end

    collection do
      EffectiveWorkExperience.WorkExperienceSummary.deep.all
    end

  end
end
