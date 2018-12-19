Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :subjects
      resources :providers
      resources :pgde_courses
      resources :organisation_users
      resources :organisation_providers
      resources :course_subjects
      resources :sites
      resources :courses
      resources :organisations
      resources :course_sites
    end
  end
end
