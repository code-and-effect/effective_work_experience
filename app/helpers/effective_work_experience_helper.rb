module EffectiveWorkExperienceHelper

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
