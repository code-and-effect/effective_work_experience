require 'effective_resources'
require 'effective_datatables'
require 'effective_work_experience/engine'
require 'effective_work_experience/version'

module EffectiveWorkExperience

  def self.config_keys
    [
      :work_experience_categories_table_name, :work_experience_subcategories_table_name,
      :work_experience_records_table_name, :work_experience_entries_table_name,
      :work_experience_projects_table_name, :work_experience_summaries_table_name,
      :work_experience_outside_mentors_table_name,

      :work_experience_summary_class_name,

      :layout, :mode, :recommendations, :summary_months,
      :mailer, :parent_mailer, :deliver_method, :mailer_layout, :mailer_sender, :mailer_admin, :mailer_subject,
      :use_effective_email_templates
    ]
  end

  include EffectiveGem

  def self.mode
    mode = config[:mode]
    raise ArgumentError, 'work experience mode must be :hours_log or :monthly_grid' unless [:hours_log, :monthly_grid].include?(mode)
    mode
  end

  # The only swappable class. Mark yours with effective_work_experience_summary
  def self.WorkExperienceSummary
    klass(:work_experience_summary)
  end

  def self.mailer_class
    mailer&.constantize || Effective::WorkExperienceMailer
  end

end
