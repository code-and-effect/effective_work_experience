module Effective
  class WorkExperienceMailer < EffectiveWorkExperience.parent_mailer_class

    include EffectiveMailer
    include EffectiveEmailTemplatesMailer if EffectiveWorkExperience.use_effective_email_templates

  end
end
