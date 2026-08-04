module Effective
  class WorkExperienceSummariesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::WizardController

    resource_scope -> {
      collection = EffectiveWorkExperience.WorkExperienceSummary.deep
      collection.where(user: current_user).or(collection.where(mentor: current_user))
    }

    def build_wizard_resource
      resource_scope.new(user: current_user)
    end

  end
end
