module EffectiveWorkExperience
  class Engine < ::Rails::Engine
    engine_name 'effective_work_experience'

    # Set up our default configuration options.
    initializer 'effective_work_experience.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_work_experience.rb")
    end

  end
end
