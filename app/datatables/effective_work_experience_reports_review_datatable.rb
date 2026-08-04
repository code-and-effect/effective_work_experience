# The work experience reports of the interns I am a mentor for
class EffectiveWorkExperienceReportsReviewDatatable < Effective::Datatable
  datatable do
    col :user, label: 'Intern'

    actions_col do |user|
      dropdown_link_to("Show #{et(Effective::WorkExperienceReport)}", effective_work_experience.work_experience_report_path(user))
    end
  end

  collection do
    current_user.work_experience_mentees.map { |user| [user, user] }
  end

end
