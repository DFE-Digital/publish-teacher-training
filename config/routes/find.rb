# frozen_string_literal: true

root to: 'find/search/locations#start', as: :find

scope via: :all do
  match '/404', to: 'find/errors#not_found'
  match '/500', to: 'find/errors#internal_server_error'
  match '/403', to: 'find/errors#forbidden'
end

namespace :find, path: '/' do
  get '/accessibility', to: 'pages#accessibility', as: :accessibility
  get '/privacy', to: 'pages#privacy', as: :privacy
  get '/terms-conditions', to: 'pages#terms', as: :terms
  get '/course/:provider_code/:course_code', to: 'courses#show', as: 'course'
  get '/course/:provider_code/:course_code/placements', to: 'placements#index', as: :placements
  get '/course/:provider_code/:course_code/apply', to: 'courses#apply', as: :apply
  get '/results', to: 'results#index', as: 'results'
  get '/location-suggestions', to: 'location_suggestions#index'
  get '/cycle-has-ended', to: 'pages#cycle_has_ended', as: 'cycle_has_ended'

  get '/feature-flags', to: 'feature_flags#index'
  post '/feature-flags' => 'feature_flags#update'
  get '/confirm-environment' => 'confirm_environment#new'
  post '/confirm-environment' => 'confirm_environment#create'
  get '/maintenance', to: 'pages#maintenance', as: 'maintenance'
  get '/cycles', to: 'switcher#cycles', as: :cycles
  post '/cycles', to: 'switcher#update', as: :switch_cycle_schedule

  resource :cookie_preferences, only: %i[show update], path: '/cookies', as: :cookies
  resource :sitemap, only: :show

  scope module: :search do
    root to: 'locations#start'
    get '/age-groups' => 'age_groups#new', as: :age_groups
    get '/age-groups-submit' => 'age_groups#create', as: :age_groups_create
    get '/subjects' => 'subjects#new', as: :subjects
    get '/subjects-submit' => 'subjects#create', as: :subjects_create
    get '/visa-status' => 'visa_status#new', as: :visa_status
    get '/visa-status-submit' => 'visa_status#create', as: :visa_status_create
    resources :locations, path: '/'
  end

  scope module: :result_filters, path: '/results/filter' do
    get 'provider', to: 'provider#new'
  end
end
