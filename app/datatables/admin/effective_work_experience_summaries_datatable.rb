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

      col :user, label: work_experience_intern_label

      if current_user.class.try(:effective_memberships_user?)
        col(:membership_categories, label: et(EffectiveMemberships.Category), sort: false, search: effective_memberships_categories) do |work_experience_summary|
          safe_join(Array(work_experience_summary.user.try(:membership).try(:membership_categories)).map do |membership_category|
            content_tag(:div, membership_category, class: 'col-resource')
          end)
        end.search do |collection, term|
          memberships = Effective::Membership.where(owner_type: current_user.class.name).with_category(term)
          collection.where(user_id: memberships.select('owner_id'))
        end
      end

      col :mentor, label: work_experience_mentor_label, visible: false

      if EffectiveWorkExperience.use_supervisor?
        col :supervisor, label: work_experience_supervisor_label, visible: false
      end

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

      col :mentor_recommendation, label: "#{work_experience_mentor_label} Recommendation", visible: false
      col :mentor_comments, label: "#{work_experience_mentor_label} Comments", visible: false

      if EffectiveWorkExperience.use_supervisor?
        col :supervisor_recommendation, label: "#{work_experience_supervisor_label} Recommendation", visible: false
        col :supervisor_comments, label: "#{work_experience_supervisor_label} Comments", visible: false
      end

      col :status_steps, visible: false
      col :wizard_steps, visible: false
      col :token, visible: false

      actions_col
    end

    collection do
      scope = EffectiveWorkExperience.WorkExperienceSummary.deep.all
      scope = scope.includes(user: :membership) if current_user.class.try(:effective_memberships_user?)
      scope
    end

  end
end
