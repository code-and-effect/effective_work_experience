namespace :effective_work_experience do

  # bundle exec rake effective_work_experience:seed
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end

  # Run once per day. Upside extends this task to process every tenant.
  desc 'Send work experience reminders and automatically approve old submissions'
  task process: :environment do
    Effective::WorkExperienceProcessor.new.process!
  end

end
