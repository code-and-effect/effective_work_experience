module Admin
  class EffectiveWorkExperienceReportsDatatable < Effective::Datatable
    datatable do
      col :user, label: 'Intern'
      col :mentor

      col(:total_hours, label: 'Total hours to date', as: :decimal) do |hours|
        work_experience_hours_to_s(hours)
      end

      actions_col(actions: []) do |user|
        dropdown_link_to('Show', effective_work_experience.admin_work_experience_report_path(user))
      end
    end

    collection do
      user_klass = current_user.class

      work_experience_records = Effective::WorkExperienceRecord.where(user_type: user_klass.name)

      users = user_klass.deep_work_experience.where(id: work_experience_records.select(:user_id))

      users.map do |user|
        [
          user,
          user.work_experience_mentor,
          user.work_experience_total_hours_to_date(month: Time.zone.now.end_of_year),
          user
        ]
      end
    end

  end
end
