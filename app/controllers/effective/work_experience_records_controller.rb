module Effective
  class WorkExperienceRecordsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> { Effective::WorkExperienceRecord.deep.where(user: current_user) }

    private

    def permitted_params
      model = (params.key?(:effective_work_experience_record) ? :effective_work_experience_record : :work_experience_record)
      params.require(model).except(:user_id, :user_type).permit!
    end

  end
end
