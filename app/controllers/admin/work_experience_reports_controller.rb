module Admin
  class WorkExperienceReportsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_work_experience) }

    include Effective::CrudController

    resource_scope -> { Effective::WorkExperienceReport }
    datatable -> { EffectiveResources.best('Admin::EffectiveWorkExperienceReportsDatatable').new }

    def show
      @user = current_user.class.find(params[:id])
      @work_experience_report = resource_scope.new(user: @user)

      @page_title = "#{EffectiveResources.et(@work_experience_report)} for #{@user}"

      EffectiveResources.authorize!(self, :show, @work_experience_report)
    end

  end
end
