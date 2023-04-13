# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

mount Sidekiq::Web, at: '/sidekiq', constraints: SystemAdminConstraint.new

root to: 'publish/providers#index'

scope via: :all do
  match '/404', to: 'publish/errors#not_found'
  match '/500', to: 'publish/errors#internal_server_error'
  match '/403', to: 'publish/errors#forbidden'
end

get '/sign-in', to: 'sign_in#index'
get '/user-not-found', to: 'sign_in#new'
get '/sign-out', to: 'sessions#sign_out'

get '/accessibility', to: 'pages#accessibility', as: :accessibility
get '/guidance', to: 'pages#guidance', as: :guidance
get '/performance-dashboard', to: 'pages#performance_dashboard', as: :performance_dashboard
get '/privacy', to: 'pages#privacy', as: :privacy
get '/terms-conditions', to: 'pages#terms', as: :terms
get '/how-to-use-this-service', to: 'pages#how_to_use_this_service'
get '/how-to-use-this-service/add-an-organisation', to: 'pages#add_an_organisation', as: :add_an_organisation
get '/how-to-use-this-service/add-and-remove-users', to: 'pages#add_and_remove_users', as: :add_and_remove_users
get '/how-to-use-this-service/change-an-accredited-provider-relationship', to: 'pages#change_an_accredited_provider_relationship', as: :change_an_accredited_provider_relationship
get '/how-to-use-this-service/roll-over-courses-to-a-new-recruitment-cycle', to: 'pages#roll_over_courses_to_a_new_recruitment_cycle', as: :roll_over_courses_to_a_new_recruitment_cycle
get '/how-to-use-this-service/course-summary-examples', to: 'pages#course_summary_examples', as: :course_summary_examples
get '/how-to-use-this-service/writing-descriptions-for-publish-teacher-training-courses', to: 'pages#writing_descriptions_for_publish_teacher_training_courses', as: :writing_descriptions_for_publish_teacher_training_courses

resource :cookie_preferences, only: %i[show update], path: '/cookies', as: :cookies

if AuthenticationService.magic_link?
  get '/sign-in/magic-link', to: 'magic_links#new', as: :magic_links
  post '/magic-link', to: 'magic_links#create'
  get '/magic-link-sent', to: 'magic_links#magic_link_sent'
  get '/signin_with_magic_link', to: 'magic_link_sessions#create', as: 'signin_with_magic_link'
  get '/auth/dfe/signout', to: 'sessions#destroy'
elsif AuthenticationService.persona?
  get '/personas', to: 'personas#index'
  post '/auth/developer/callback', to: 'sessions#callback'
  get '/auth/developer/signout', to: 'sessions#destroy'
else
  get '/auth/dfe/callback', to: 'sessions#callback'
  get '/auth/dfe/signout', to: 'sessions#destroy'
end

namespace :publish, as: :publish do
  get '/organisations', to: 'providers#index', as: :root
  get '/providers/search', to: 'providers#search'
  get '/providers/suggest', to: 'providers#suggest'
  get '/rollover-recruitment', to: 'rollover_recruitment#new', as: :rollover_recruitment
  post '/rollover-recruitment', to: 'rollover_recruitment#create'

  get '/accept-terms', to: 'terms#edit', as: :accept_terms
  patch '/accept-terms', to: 'terms#update'

  resources :notifications, path: '/notifications', controller: 'notifications', only: %i[index update]

  resources :access_requests, path: '/access-requests', controller: 'access_requests', only: %i[new index create] do
    member do
      post :approve
      delete :destroy
      get :confirm
      get '/inform-publisher', to: 'access_requests#inform_publisher'
    end
  end

  resources :providers, path: 'organisations', param: :code, only: [:show] do
    resource :check_user, only: %i[show update], controller: 'users_check', path: 'users/check'
    resources :users, controller: 'users' do
      resource :edit_check, controller: 'users_edit_check', path: 'edit/check'
      member do
        get :delete
        delete :delete, to: 'users#destroy'
      end
    end

    get '/request-access', on: :member, to: 'providers/access_requests#new'
    post '/request-access', on: :member, to: 'providers/access_requests#create'
    get 'schools'

    resources :recruitment_cycles, param: :year, constraints: { year: /#{Settings.current_recruitment_cycle_year}|#{Settings.current_recruitment_cycle_year + 1}/ }, path: '', only: [:show] do
      get '/about', on: :member, to: 'providers#about'
      put '/about', on: :member, to: 'providers#update'
      get '/details', on: :member, to: 'providers#details'
      get '/training-providers-courses', on: :member, to: 'training_providers/course_exports#index', as: 'download_training_providers_courses'

      resources :training_providers, path: '/training-providers', only: [:index], param: :code do
        resources :courses, only: [:index], controller: 'training_providers/courses'
      end

      resource :courses, only: %i[create] do
        resource :outcome, on: :member, only: %i[new], controller: 'courses/outcome' do
          get 'continue'
        end
        resource :entry_requirements, on: :member, only: %i[new], controller: 'courses/entry_requirements', path: 'entry-requirements' do
          get 'continue'
        end
        resource :study_mode, on: :member, only: %i[new], controller: 'courses/study_mode', path: 'full-part-time' do
          get 'continue'
        end
        resource :level, on: :member, only: %i[new], controller: 'courses/level' do
          get 'continue'
        end
        resource :schools, on: :member, only: %i[new], controller: 'courses/schools' do
          get 'back'
          get 'continue'
        end
        resource :start_date, on: :member, only: %i[new], controller: 'courses/start_date', path: 'start-date' do
          get 'continue'
        end
        resource :applications_open, on: :member, only: %i[new], controller: 'courses/applications_open', path: 'applications-open' do
          get 'continue'
        end
        resource :age_range, on: :member, only: %i[new], controller: 'courses/age_range', path: 'age-range' do
          get 'continue'
        end
        resource :subjects, on: :member, only: %i[new], controller: 'courses/subjects', path: 'subjects' do
          get 'continue'
        end
        resource :engineers_teach_physics, on: :member, only: %i[new], controller: 'courses/engineers_teach_physics', path: 'engineers-teach-physics' do
          get 'continue'
          get 'back'
        end
        resource :modern_languages, on: :member, only: %i[new], controller: 'courses/modern_languages', path: 'modern-languages' do
          get 'back'
          get 'continue'
        end
        resource :apprenticeship, on: :member, only: %i[new], controller: 'courses/apprenticeship' do
          get 'continue'
        end
        resource :accredited_body, on: :member, only: %i[new], controller: 'courses/accredited_body', path: 'accredited-body' do
          get 'continue'
          get 'search_new'
        end
        resource :student_visa_sponsorship, on: :member, controller: 'courses/student_visa_sponsorship', path: 'student-visa-sponsorship' do
          get 'continue'
        end
        resource :skilled_worker_visa_sponsorship, on: :member, controller: 'courses/skilled_worker_visa_sponsorship', path: 'skilled-worker-visa-sponsorship' do
          get 'continue'
        end
        resource :funding_type, on: :member, only: %i[new], controller: 'courses/funding_type', path: 'funding-type' do
          get 'continue'
        end

        get 'confirmation'
      end

      resources :courses, param: :code, only: %i[index new create show] do
        get '/apply', on: :member, to: 'courses#apply', as: :apply
        get '/details', on: :member, to: 'courses#details'

        get '/engineers_teach_physics', on: :member, to: 'courses/engineers_teach_physics#edit'
        put '/engineers_teach_physics', on: :member, to: 'courses/engineers_teach_physics#update'

        get '/age_range', on: :member, to: 'courses/age_range#edit'
        put '/age_range', on: :member, to: 'courses/age_range#update'

        get '/vacancies', on: :member, to: 'courses/vacancies#edit'
        put '/vacancies', on: :member, to: 'courses/vacancies#update'

        get '/about', on: :member, to: 'courses/course_information#edit'
        patch '/about', on: :member, to: 'courses/course_information#update'
        get '/requirements', on: :member, to: 'courses/requirements#edit'
        patch '/requirements', on: :member, to: 'courses/requirements#update'
        get '/fees', on: :member, to: 'courses/fees#edit'
        patch '/fees', on: :member, to: 'courses/fees#update'
        get '/salary', on: :member, to: 'courses/salary#edit'
        patch '/salary', on: :member, to: 'courses/salary#update'

        get '/withdraw', on: :member, to: 'courses/withdrawals#edit'
        patch '/withdraw', on: :member, to: 'courses/withdrawals#update'
        get '/delete', on: :member, to: 'courses/deletions#edit'
        delete '/delete', on: :member, to: 'courses/deletions#destroy'
        post '/publish', on: :member, to: 'courses#publish'

        get '/rollover', on: :member, to: 'courses/draft_rollover#edit'
        post '/rollover', on: :member, to: 'courses/draft_rollover#update'

        get '/schools', on: :member, to: 'courses/schools#edit'
        put '/schools', on: :member, to: 'courses/schools#update'

        get '/preview', on: :member, to: 'courses#preview'

        get '/outcome', on: :member, to: 'courses/outcome#edit'
        put '/outcome', on: :member, to: 'courses/outcome#update'

        get '/full-part-time', on: :member, to: 'courses/study_mode#edit'
        put '/full-part-time', on: :member, to: 'courses/study_mode#update'

        get '/degrees/start', on: :member, to: 'courses/degrees/start#edit'
        put '/degrees/start', on: :member, to: 'courses/degrees/start#update'

        get '/degrees/grade', on: :member, to: 'courses/degrees/grade#edit'
        put '/degrees/grade', on: :member, to: 'courses/degrees/grade#update'

        get '/degrees/subject-requirements', on: :member, to: 'courses/degrees/subject_requirements#edit'
        put '/degrees/subject-requirements', on: :member, to: 'courses/degrees/subject_requirements#update'

        get '/gcses-pending-or-equivalency-tests', on: :member, to: 'courses/gcse_requirements#edit'
        put '/gcses-pending-or-equivalency-tests', on: :member, to: 'courses/gcse_requirements#update'

        get '/subjects', on: :member, to: 'courses/subjects#edit'
        put '/subjects', on: :member, to: 'courses/subjects#update'

        get '/modern-languages', on: :member, to: 'courses/modern_languages#edit'
        put '/modern-languages', on: :member, to: 'courses/modern_languages#update'

        get '/student-visa-sponsorship', on: :member, to: 'courses/student_visa_sponsorship#edit'
        put '/student-visa-sponsorship', on: :member, to: 'courses/student_visa_sponsorship#update'

        get '/skilled-worker-visa-sponsorship', on: :member, to: 'courses/skilled_worker_visa_sponsorship#edit'
        put '/skilled-worker-visa-sponsorship', on: :member, to: 'courses/skilled_worker_visa_sponsorship#update'

        get '/funding-type', on: :member, to: 'courses/funding_type#edit'
        put '/funding-type', on: :member, to: 'courses/funding_type#update'

        get '/apprenticeship', on: :member, to: 'courses/apprenticeship#edit'
        put '/apprenticeship', on: :member, to: 'courses/apprenticeship#update'
      end

      scope module: :providers do
        resource :check_school, only: %i[show update], controller: 'schools_check', path: 'schools/check'
        resources :schools do
          member do
            get :delete
            delete :delete, to: 'schools#destroy'
          end

          get '/search', on: :collection, to: 'school_search#new'
          post '/search', on: :collection, to: 'school_search#create'
          put '/search', on: :collection, to: 'school_search#update'
        end

        get '/contact', on: :member, to: 'contacts#edit'
        put '/contact', on: :member, to: 'contacts#update'
        get '/student-visa', on: :member, to: 'student_visa#edit'
        get '/skilled-worker-visa', on: :member, to: 'skilled_worker_visa#edit'
        put '/student-visa', on: :member, to: 'student_visa#update'
        put '/skilled-worker-visa', on: :member, to: 'skilled_worker_visa#update'
      end
    end
  end
end
