module Admin
  class WorkExperienceSubcategoriesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_work_experience) }

    include Effective::CrudController

    resource_scope -> { Effective::WorkExperienceSubcategory.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveWorkExperienceSubcategoriesDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_work_experience_subcategory) ? :effective_work_experience_subcategory : :work_experience_subcategory)
      params.require(model).permit!
    end

  end
end
