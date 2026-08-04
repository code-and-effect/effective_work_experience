# My work experience records
class EffectiveWorkExperienceRecordsDatatable < Effective::Datatable
  datatable do
    order :month, :desc

    col :updated_at, visible: false
    col :created_at, visible: false
    col :id, visible: false

    col(:month) do |work_experience_record|
      work_experience_record.month&.strftime('%F') || 'Backdated'
    end

    col(:total_hours, label: 'Hours') do |work_experience_record|
      work_experience_hours_to_s(work_experience_record.total_hours)
    end.aggregate do |work_experience_records|
      total = work_experience_records.sum { |work_experience_record| work_experience_record.total_hours }
      work_experience_hours_to_s(total)
    end

    col(:status) do |work_experience_record|
      work_experience_record.status unless work_experience_record.backdated?
    end

    col(:submitted_at, label: 'Submitted') do |work_experience_record|
      unless work_experience_record.backdated?
        work_experience_record.submitted_at&.strftime('%F') || 'Not yet submitted'
      end
    end

    col(:reviewed_at, label: 'Reviewed', as: :date) do |work_experience_record|
      unless work_experience_record.backdated?
        work_experience_record.reviewed_at&.strftime('%F') || 'Not yet reviewed'
      end
    end

    aggregate :total

    unless attributes[:skip_actions]
      actions_col
    end
  end

  collection do
    scope = Effective::WorkExperienceRecord.deep.all
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
