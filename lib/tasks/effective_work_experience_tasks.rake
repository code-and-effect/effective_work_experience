namespace :effective_work_experience do

  # bundle exec rake effective_work_experience:seed
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end

end
