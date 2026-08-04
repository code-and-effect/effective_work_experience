module EffectiveWorkExperience
  class Engine < ::Rails::Engine
    engine_name 'effective_work_experience'

    # Set up our default configuration options.
    initializer 'effective_work_experience.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_work_experience.rb")
    end

    # Include the work experience concerns and allow any ActiveRecord object to call them
    initializer 'effective_work_experience.active_record' do |app|
      app.config.to_prepare do
        ActiveRecord::Base.extend(EffectiveWorkExperienceSummary::Base)
        ActiveRecord::Base.extend(EffectiveWorkExperienceUser::Base)
      end
    end

  end
end
