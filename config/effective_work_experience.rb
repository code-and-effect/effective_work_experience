EffectiveWorkExperience.setup do |config|
  # Configure Database Tables
  config.work_experience_categories_table_name = :work_experience_categories
  config.work_experience_subcategories_table_name = :work_experience_subcategories
  config.work_experience_records_table_name = :work_experience_records
  config.work_experience_entries_table_name = :work_experience_entries
  config.work_experience_projects_table_name = :work_experience_projects
  config.work_experience_summaries_table_name = :work_experience_summaries
  config.work_experience_outside_mentors_table_name = :work_experience_outside_mentors

  # Configure the class responsible for the work experience summary
  # Any class you provide here should be marked with effective_work_experience_summary
  # config.work_experience_summary_class_name = 'Effective::WorkExperienceSummary'

  # The number of months in each work experience summary period
  # Display only for now. Every period is one calendar quarter.
  config.summary_months = 3

  # The recommendations a mentor may make when reviewing a work experience summary
  config.recommendations = ['Recommend Approve', 'Recommend Decline']

  # Layout Settings
  # Configure the Layout per controller, or all at once
  # config.layout = { application: 'application', admin: 'admin' }

  # Mailer Settings
  # Please see config/initializers/effective_resources.rb for default effective_* gem mailer settings
  #
  # Configure the class responsible to send e-mails.
  # config.mailer = 'Effective::WorkExperienceMailer'
  #
  # Override effective_resource mailer defaults
  #
  # config.parent_mailer = nil      # The parent class responsible for sending emails
  # config.deliver_method = nil     # The deliver method, deliver_later or deliver_now
  # config.mailer_layout = nil      # Default mailer layout
  # config.mailer_sender = nil      # Default From value
  # config.mailer_admin = nil       # Default To value for Admin correspondence
  # config.mailer_subject = nil     # Proc.new method used to customize Subject

  # Will work with effective_email_templates gem
  config.use_effective_email_templates = true
end
