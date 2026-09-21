module Effective
  class WorkExperienceProcessor
    def process!
      remind!
      auto_approve!
    end

    def remind!
      today = Time.zone.today

      EffectiveWorkExperience.WorkExperienceSummary.needs_reminder.find_each do |summary|
        due_on = summary.end_on + 15.days

        send_email(:work_experience_summary_reminder_end_of_quarter, summary) if today == summary.end_on + 1.day
        send_email(:work_experience_summary_reminder_due, summary) if today == due_on

        if today > due_on
          send_email(:work_experience_summary_reminder_late_daily, summary)
          send_email(:work_experience_summary_reminder_late_biweekly, summary) if [1, 15].include?(today.day)
        end
      end
    end

    def auto_approve!
      EffectiveWorkExperience.WorkExperienceSummary.needs_auto_approval.find_each do |summary|
        summary.auto_approve!
      rescue => error
        EffectiveResources.send_error(error, work_experience_summary_id: summary.id)
      end
    end

    private

    def send_email(email, summary)
      EffectiveWorkExperience.send_email(email, summary)
    end
  end
end
