require 'effective_resources'
require 'effective_datatables'
require 'effective_work_experience/engine'
require 'effective_work_experience/version'

module EffectiveWorkExperience

  def self.config_keys
    [
      :layout,
      :mailer, :parent_mailer, :deliver_method, :mailer_layout, :mailer_sender, :mailer_admin, :mailer_subject,
      :use_effective_email_templates
    ]
  end

  include EffectiveGem

  def self.mailer_class
    mailer&.constantize || Effective::WorkExperienceMailer
  end

end
