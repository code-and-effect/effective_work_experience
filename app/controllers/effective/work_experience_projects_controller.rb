module Effective
  class WorkExperienceProjectsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> { Effective::WorkExperienceProject.deep.where(user: current_user) }

    private

    def permitted_params
      model = (params.key?(:effective_work_experience_project) ? :effective_work_experience_project : :work_experience_project)
      params.require(model).except(:user_id, :user_type).permit!
    end

  end
end
