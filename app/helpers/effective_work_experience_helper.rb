module EffectiveWorkExperienceHelper

  def work_experience_name_label
    et('effective_work_experience.name')
  end

  def work_experience_mentor_label
    et(EffectiveWorkExperience.WorkExperienceSummary, :mentor)
  end

  def work_experience_mentors_label
    ets(EffectiveWorkExperience.WorkExperienceSummary, :mentor)
  end

  def work_experience_intern_label
    et(EffectiveWorkExperience.WorkExperienceSummary, :user)
  end

  def work_experience_interns_label
    ets(EffectiveWorkExperience.WorkExperienceSummary, :user)
  end

  def work_experience_supervisor_label
    et(EffectiveWorkExperience.WorkExperienceSummary, :supervisor)
  end

  def work_experience_supervisors_label
    ets(EffectiveWorkExperience.WorkExperienceSummary, :supervisor)
  end

  def work_experience_activity_label
    et(Effective::WorkExperienceActivity)
  end

  def work_experience_activities_label
    ets(Effective::WorkExperienceActivity)
  end

  def work_experience_record_label
    et(Effective::WorkExperienceRecord)
  end

  def work_experience_records_label
    ets(Effective::WorkExperienceRecord)
  end

  def work_experience_entry_label
    et(Effective::WorkExperienceEntry)
  end

  def work_experience_entries_label
    ets(Effective::WorkExperienceEntry)
  end

  def work_experience_project_label
    et(Effective::WorkExperienceProject)
  end

  def work_experience_projects_label
    ets(Effective::WorkExperienceProject)
  end

  def work_experience_summary_label
    et(EffectiveWorkExperience.WorkExperienceSummary)
  end

  def work_experience_summaries_label
    ets(EffectiveWorkExperience.WorkExperienceSummary)
  end

  def work_experience_report_label
    et(Effective::WorkExperienceReport)
  end

  def work_experience_reports_label
    ets(Effective::WorkExperienceReport)
  end

  def work_experience_category_label
    et(Effective::WorkExperienceCategory)
  end

  def work_experience_categories_label
    ets(Effective::WorkExperienceCategory)
  end

  def work_experience_subcategory_label
    et(Effective::WorkExperienceSubcategory)
  end

  def work_experience_subcategories_label
    ets(Effective::WorkExperienceSubcategory)
  end

  # Display hours with one decimal place
  def work_experience_hours_to_s(hours)
    return if hours.blank?
    "%0.1f" % hours
  end

  # Display a collection of every summary period going back 10 years
  def work_experience_summary_start_on_collection(work_experience_summary = nil)
    disabled = if work_experience_summary.present?
      work_experience_summary.user.work_experience_summaries.where.not(id: work_experience_summary.id).pluck(:start_on)
    end

    disabled ||= []

    date = Time.zone.now.beginning_of_quarter
    end_date = (date - 10.years).beginning_of_year

    collection = []

    while date >= end_date
      start_on = date.beginning_of_quarter
      end_on = date.end_of_quarter

      collection << [
        "#{start_on.strftime('%B %Y')} to #{end_on.strftime('%B %Y')}",
        date.strftime('%Y-%m-%d'),
        disabled: disabled.include?(date)
      ]

      date -= 3.months
    end

    collection
  end

  def work_experience_summary_status_collection
    EffectiveWorkExperience.WorkExperienceSummary::STATUSES
  end

  def work_experience_recommendation_collection
    Array(EffectiveWorkExperience.recommendations)
  end

end
