# frozen_string_literal: true

root to: 'find/homepage#index', as: :find

scope via: :all do
  match '/404', to: 'find/errors#not_found'
  match '/500', to: 'find/errors#internal_server_error'
  match '/403', to: 'find/errors#forbidden'
end

namespace :find, path: '/' do
  get 'track_click', to: 'track#track_click'

  get '/accessibility', to: 'pages#accessibility', as: :accessibility
  get '/privacy', to: 'pages#privacy', as: :privacy
  get '/terms-conditions', to: 'pages#terms', as: :terms
  get '/course/:provider_code/:course_code', to: 'courses#show', as: 'course'
  get '/course/:provider_code/:course_code/placements', to: 'placements#index', as: :placements
  get '/course/:provider_code/:course_code/apply', to: 'courses#apply', as: :apply
  get '/course/:provider_code/:course_code/git/:git_path', to: 'courses#git_redirect', as: :get_into_teaching_redirect
  get '/course/:provider_code/:course_code/provider/website', to: 'courses#provider_website', as: :provider_website

  get '/geolocation-suggestions', to: 'geolocation_suggestions#index'

  get '/results', to: 'v2/results#index', as: 'results'
  get '/primary', to: 'v2/primary_subjects#index'
  post '/primary', to: 'v2/primary_subjects#submit'
  get '/secondary', to: 'v2/secondary_subjects#index'
  post '/secondary', to: 'v2/secondary_subjects#submit'

  get '/cycle-has-ended', to: 'pages#cycle_has_ended', as: 'cycle_has_ended'

  scope module: :courses, path: '/courses' do
    get '/:provider_code/:course_code/provider', to: 'providers#show', as: :provider
    get '/:provider_code/:course_code/accredited-by', to: 'accrediting_providers#show', as: :accrediting_provider
    get '/:provider_code/:course_code/training-with-disabilities', to: 'training_with_disabilities#show', as: :training_with_disabilities
  end

  get '/feature-flags', to: 'feature_flags#index'
  post '/feature-flags' => 'feature_flags#update'
  get '/confirm-environment' => 'confirm_environment#new'
  post '/confirm-environment' => 'confirm_environment#create'
  get '/maintenance', to: 'pages#maintenance', as: 'maintenance'
  get '/cycles', to: 'switcher#cycles', as: :cycles
  post '/cycles', to: 'switcher#update', as: :switch_cycle_schedule

  resource :cookie_preferences, only: %i[show update], path: '/cookies', as: :cookies
  resource :sitemap, only: :show
end
