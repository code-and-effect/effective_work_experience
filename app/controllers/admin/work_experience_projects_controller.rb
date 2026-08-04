module Admin
  class WorkExperienceProjectsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_work_experience) }

    include Effective::CrudController

    resource_scope -> { Effective::WorkExperienceProject.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveWorkExperienceProjectsDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_work_experience_project) ? :effective_work_experience_project : :work_experience_project)
      params.require(model).permit!
    end

  end
end
