module EffectiveWorkExperience
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc 'Creates an EffectiveWorkExperience initializer in your application.'

      source_root File.expand_path('../../templates', __FILE__)

      def self.next_migration_number(dirname)
        ActiveRecord::Migration.next_migration_number(current_migration_number(dirname) + 1)
      end

      def copy_initializer
        template ('../' * 3) + 'config/effective_work_experience.rb', 'config/initializers/effective_work_experience.rb'
      end

      def create_migration_file
        migration_template ('../' * 3) + 'db/migrate/101_create_effective_work_experience.rb', 'db/migrate/create_effective_work_experience.rb'
      end

    end
  end
end
