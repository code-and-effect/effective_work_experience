module Admin
  class WorkExperienceCategoriesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_work_experience) }

    include Effective::CrudController

    resource_scope -> { Effective::WorkExperienceCategory.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveWorkExperienceCategoriesDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_work_experience_category) ? :effective_work_experience_category : :work_experience_category)
      params.require(model).permit!
    end

  end
end
