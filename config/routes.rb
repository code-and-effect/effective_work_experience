# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveWorkExperience::Engine => '/', as: 'effective_work_experience'
end

EffectiveWorkExperience::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
    resources :work_experience_records
    resources :work_experience_projects
    resources :work_experience_reports, only: [:show]

    resources :work_experience_summaries, only: [:new, :create, :show, :destroy] do
      resources :build, controller: :work_experience_summaries, only: [:show, :update]
    end
  end

  namespace :admin do
    resources :work_experience_categories, only: [:index, :show, :edit, :update]
    resources :work_experience_subcategories, except: [:show]
    resources :work_experience_projects
    resources :work_experience_records
    resources :work_experience_reports, only: [:index, :show]
    resources :work_experience_summaries, only: [:index, :show, :edit, :update, :destroy]
  end

end
