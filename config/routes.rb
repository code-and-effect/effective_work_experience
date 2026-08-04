# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveWorkExperience::Engine => '/', as: 'effective_work_experience'
end

EffectiveWorkExperience::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
  end

  namespace :admin do
  end

end
