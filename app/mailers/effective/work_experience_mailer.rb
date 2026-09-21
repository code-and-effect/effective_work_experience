module Effective
  class WorkExperienceMailer < EffectiveWorkExperience.parent_mailer_class

    include EffectiveMailer
    include EffectiveEmailTemplatesMailer

    def work_experience_summary_submitted(resource, opts = {})
      @assigns = work_experience_summary_assigns(resource)
      mail(to: resource.mentor.email, **headers_for(resource, opts))
    end

    def work_experience_summary_submitted_two(resource, opts = {})
      @assigns = work_experience_summary_assigns(resource)
      mail(to: resource.supervisor.email, **headers_for(resource, opts))
    end

    def work_experience_summary_reviewed(resource, opts = {})
      @assigns = work_experience_summary_assigns(resource)
      mail(to: resource.user.email, **headers_for(resource, opts))
    end

    def work_experience_summary_reviewed_two(resource, opts = {})
      @assigns = work_experience_summary_assigns(resource)
      mail(to: resource.user.email, **headers_for(resource, opts))
    end

    def work_experience_summary_declined(resource, opts = {})
      @assigns = work_experience_summary_assigns(resource)
      mail(to: resource.user.email, **headers_for(resource, opts))
    end

    protected

    def assigns_for(resource)
      return work_experience_summary_assigns(resource) if resource.class.try(:effective_work_experience_summary?)
      raise('unexpected resource')
    end

    def work_experience_summary_assigns(resource)
      raise('expected a work experience summary') unless resource.class.try(:effective_work_experience_summary?)

      user = resource.user
      mentor = resource.mentor
      supervisor = resource.supervisor

      {
        user: { name: user.try(:email_to_s) || user.to_s, email: user.email },
        mentor: { name: mentor.try(:email_to_s) || mentor.to_s, email: mentor.try(:email) },
        supervisor: { name: supervisor.try(:email_to_s) || supervisor.to_s, email: supervisor.try(:email) },
        intern_label: EffectiveResources.et('effective_work_experience.intern').downcase,
        mentor_label: EffectiveResources.et('effective_work_experience.mentor').downcase,
        supervisor_label: EffectiveResources.et('effective_work_experience.supervisor').downcase,
        summary_label: EffectiveResources.et(EffectiveWorkExperience.WorkExperienceSummary).downcase,
        period: resource.period,
        url: link_to(effective_work_experience.work_experience_summary_url(resource))
      }
    end

  end
end
