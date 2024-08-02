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
  get '/course/:provider_code/:course_code/git/:git_path', to: 'courses#git_redirect', as: :get_into_teaching_redirect
  get '/course/:provider_code/:course_code/provider/website', to: 'courses#provider_website', as: :provider_website
  get '/results', to: 'results#index', as: 'results'
  get '/location-suggestions', to: 'location_suggestions#index'
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

  scope module: :search do
    root to: 'locations#start'
    get '/age-groups' => 'age_groups#new', as: :age_groups
    get '/age-groups-submit' => 'age_groups#create', as: :age_groups_create
    get '/subjects' => 'subjects#new', as: :subjects
    get '/subjects-submit' => 'subjects#create', as: :subjects_create
    get '/university-degree-status' => 'university_degree_status#new', as: :university_degree_status
    get '/university-degree-status-create' => 'university_degree_status#create', as: :university_degree_status_create
    get '/visa-status' => 'visa_status#new', as: :visa_status
    get '/visa-status-submit' => 'visa_status#create', as: :visa_status_create
    get '/no-degree-and-requires-visa-sponsorship' => 'no_degree_and_requires_visa_sponsorship#new', as: :no_degree_and_requires_visa_sponsorship
    resources :locations, path: '/'
  end

  scope module: :result_filters, path: '/results/filter' do
    get 'provider', to: 'provider#new'
  end
end
