module Admin
  class WorkExperienceSummariesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_work_experience) }

    include Effective::CrudController

    resource_scope -> { EffectiveWorkExperience.WorkExperienceSummary.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveWorkExperienceSummariesDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_work_experience_summary) ? :effective_work_experience_summary : :work_experience_summary)
      params.require(model).permit!
    end

  end
end
