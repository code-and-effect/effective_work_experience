module Admin
  class EffectiveWorkExperienceRecordsDatatable < Effective::Datatable
    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :user, label: 'Intern'

      col(:month) do |work_experience_record|
        work_experience_record.month&.strftime('%F') || 'Backdated'
      end

      col(:total_hours, label: 'Hours') do |work_experience_record|
        work_experience_hours_to_s(work_experience_record.total_hours)
      end.aggregate do |work_experience_records|
        total = work_experience_records.sum { |work_experience_record| work_experience_record.total_hours }
        work_experience_hours_to_s(total)
      end

      col :status, visible: false
      col :submitted_at, visible: false
      col :reviewed_at, visible: false

      aggregate :total

      actions_col
    end

    collection do
      Effective::WorkExperienceRecord.deep.all
    end

  end
end
