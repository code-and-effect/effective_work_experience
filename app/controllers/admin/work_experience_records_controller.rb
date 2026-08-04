module Admin
  class WorkExperienceRecordsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_work_experience) }

    include Effective::CrudController

    resource_scope -> { Effective::WorkExperienceRecord.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveWorkExperienceRecordsDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_work_experience_record) ? :effective_work_experience_record : :work_experience_record)
      params.require(model).permit!
    end

  end
end
