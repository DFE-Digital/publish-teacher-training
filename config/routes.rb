# == Route Map
#
#                                                                Prefix Verb   URI Pattern                                                                                                                      Controller#Action
#                                                      api_v1_providers GET    /api/v1(/:recruitment_year)/providers(.:format)                                                                                  api/v1/providers#index
#                                                                       POST   /api/v1(/:recruitment_year)/providers(.:format)                                                                                  api/v1/providers#create
#                                                       api_v1_provider GET    /api/v1(/:recruitment_year)/providers/:id(.:format)                                                                              api/v1/providers#show
#                                                                       PATCH  /api/v1(/:recruitment_year)/providers/:id(.:format)                                                                              api/v1/providers#update
#                                                                       PUT    /api/v1(/:recruitment_year)/providers/:id(.:format)                                                                              api/v1/providers#update
#                                                                       DELETE /api/v1(/:recruitment_year)/providers/:id(.:format)                                                                              api/v1/providers#destroy
#                                                       api_v1_subjects GET    /api/v1(/:recruitment_year)/subjects(.:format)                                                                                   api/v1/subjects#index
#                                                                       POST   /api/v1(/:recruitment_year)/subjects(.:format)                                                                                   api/v1/subjects#create
#                                                        api_v1_subject GET    /api/v1(/:recruitment_year)/subjects/:id(.:format)                                                                               api/v1/subjects#show
#                                                                       PATCH  /api/v1(/:recruitment_year)/subjects/:id(.:format)                                                                               api/v1/subjects#update
#                                                                       PUT    /api/v1(/:recruitment_year)/subjects/:id(.:format)                                                                               api/v1/subjects#update
#                                                                       DELETE /api/v1(/:recruitment_year)/subjects/:id(.:format)                                                                               api/v1/subjects#destroy
#                                                        api_v1_courses GET    /api/v1(/:recruitment_year)/courses(.:format)                                                                                    api/v1/courses#index
#                                                                       POST   /api/v1(/:recruitment_year)/courses(.:format)                                                                                    api/v1/courses#create
#                                                         api_v1_course GET    /api/v1(/:recruitment_year)/courses/:id(.:format)                                                                                api/v1/courses#show
#                                                                       PATCH  /api/v1(/:recruitment_year)/courses/:id(.:format)                                                                                api/v1/courses#update
#                                                                       PUT    /api/v1(/:recruitment_year)/courses/:id(.:format)                                                                                api/v1/courses#update
#                                                                       DELETE /api/v1(/:recruitment_year)/courses/:id(.:format)                                                                                api/v1/courses#destroy
#                                                 api_v2_user_providers GET    /api/v2/users/:user_id/providers(.:format)                                                                                       api/v2/providers#index
#                                                                       POST   /api/v2/users/:user_id/providers(.:format)                                                                                       api/v2/providers#create
#                                                  api_v2_user_provider GET    /api/v2/users/:user_id/providers/:id(.:format)                                                                                   api/v2/providers#show
#                                                                       PATCH  /api/v2/users/:user_id/providers/:id(.:format)                                                                                   api/v2/providers#update
#                                                                       PUT    /api/v2/users/:user_id/providers/:id(.:format)                                                                                   api/v2/providers#update
#                                                                       DELETE /api/v2/users/:user_id/providers/:id(.:format)                                                                                   api/v2/providers#destroy
#                                  accept_transition_screen_api_v2_user PATCH  /api/v2/users/:id/accept_transition_screen(.:format)                                                                             api/v2/users#accept_transition_screen
#                                    accept_rollover_screen_api_v2_user PATCH  /api/v2/users/:id/accept_rollover_screen(.:format)                                                                               api/v2/users#accept_rollover_screen
#                                                           api_v2_user GET    /api/v2/users/:id(.:format)                                                                                                      api/v2/users#show
#                                                                       PATCH  /api/v2/users/:id(.:format)                                                                                                      api/v2/users#update
#                                                                       PUT    /api/v2/users/:id(.:format)                                                                                                      api/v2/users#update
#                                    api_v2_provider_recruitment_cycles GET    /api/v2/providers/:provider_code/recruitment_cycles(.:format)                                                                    api/v2/recruitment_cycles#index
#                   sync_with_search_and_compare_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/sync_with_search_and_compare(.:format)                                            api/v2/courses#sync_with_search_and_compare
#                                        publish_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/publish(.:format)                                                                 api/v2/courses#publish
#                                    publishable_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/publishable(.:format)                                                             api/v2/courses#publishable
#                                               api_v2_provider_courses GET    /api/v2/providers/:provider_code/courses(.:format)                                                                               api/v2/courses#index
#                                                                       POST   /api/v2/providers/:provider_code/courses(.:format)                                                                               api/v2/courses#create
#                                                api_v2_provider_course GET    /api/v2/providers/:provider_code/courses/:code(.:format)                                                                         api/v2/courses#show
#                                                                       PATCH  /api/v2/providers/:provider_code/courses/:code(.:format)                                                                         api/v2/courses#update
#                                                                       PUT    /api/v2/providers/:provider_code/courses/:code(.:format)                                                                         api/v2/courses#update
#                                                 api_v2_provider_sites GET    /api/v2/providers/:provider_code/sites(.:format)                                                                                 api/v2/sites#index
#                                                                       POST   /api/v2/providers/:provider_code/sites(.:format)                                                                                 api/v2/sites#create
#                                                  api_v2_provider_site GET    /api/v2/providers/:provider_code/sites/:id(.:format)                                                                             api/v2/sites#show
#                                                                       PATCH  /api/v2/providers/:provider_code/sites/:id(.:format)                                                                             api/v2/sites#update
#                                                                       PUT    /api/v2/providers/:provider_code/sites/:id(.:format)                                                                             api/v2/sites#update
#                                                      api_v2_providers GET    /api/v2/providers(.:format)                                                                                                      api/v2/providers#index
#                                                                       POST   /api/v2/providers(.:format)                                                                                                      api/v2/providers#create
#                                                       api_v2_provider GET    /api/v2/providers/:code(.:format)                                                                                                api/v2/providers#show
#                                                                       PATCH  /api/v2/providers/:code(.:format)                                                                                                api/v2/providers#update
#                                                                       PUT    /api/v2/providers/:code(.:format)                                                                                                api/v2/providers#update
#                                                                       DELETE /api/v2/providers/:code(.:format)                                                                                                api/v2/providers#destroy
# sync_with_search_and_compare_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/sync_with_search_and_compare(.:format) api/v2/courses#sync_with_search_and_compare
#                      publish_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/publish(.:format)                      api/v2/courses#publish
#                  publishable_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/publishable(.:format)                  api/v2/courses#publishable
#                             api_v2_recruitment_cycle_provider_courses GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses(.:format)                                    api/v2/courses#index
#                                                                       POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses(.:format)                                    api/v2/courses#create
#                              api_v2_recruitment_cycle_provider_course GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                              api/v2/courses#show
#                                                                       PATCH  /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                              api/v2/courses#update
#                                                                       PUT    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                              api/v2/courses#update
#                               api_v2_recruitment_cycle_provider_sites GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites(.:format)                                      api/v2/sites#index
#                                                                       POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites(.:format)                                      api/v2/sites#create
#                                api_v2_recruitment_cycle_provider_site GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                  api/v2/sites#show
#                                                                       PATCH  /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                  api/v2/sites#update
#                                                                       PUT    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                  api/v2/sites#update
#                                    api_v2_recruitment_cycle_providers GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers(.:format)                                                           api/v2/providers#index
#                                     api_v2_recruitment_cycle_provider GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                     api/v2/providers#show
#                                             api_v2_recruitment_cycles GET    /api/v2/recruitment_cycles(.:format)                                                                                             api/v2/recruitment_cycles#index
#                                              api_v2_recruitment_cycle GET    /api/v2/recruitment_cycles/:year(.:format)                                                                                       api/v2/recruitment_cycles#show
#                                                       api_v2_sessions GET    /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#show
#                                                                       PATCH  /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#update
#                                                                       PUT    /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#update
#                                                                       DELETE /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#destroy
#                                                                       POST   /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#create
#                                                    api_v2_site_status PATCH  /api/v2/site_statuses/:id(.:format)                                                                                              api/v2/site_statuses#update
#                                                                       PUT    /api/v2/site_statuses/:id(.:format)                                                                                              api/v2/site_statuses#update
#                                         approve_api_v2_access_request POST   /api/v2/access_requests/:id/approve(.:format)                                                                                    api/v2/access_requests#approve
#                                                api_v2_access_requests GET    /api/v2/access_requests(.:format)                                                                                                api/v2/access_requests#index
#                                                                       POST   /api/v2/access_requests(.:format)                                                                                                api/v2/access_requests#create
#                                                 api_v2_access_request GET    /api/v2/access_requests/:id(.:format)                                                                                            api/v2/access_requests#show
#                                                                       PATCH  /api/v2/access_requests/:id(.:format)                                                                                            api/v2/access_requests#update
#                                                                       PUT    /api/v2/access_requests/:id(.:format)                                                                                            api/v2/access_requests#update
#                                                             error_500 GET    /error_500(.:format)                                                                                                             error#error_500
#                                                            error_nodb GET    /error_nodb(.:format)                                                                                                            error#error_nodb

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      scope "/(:recruitment_year)" do
        resources :providers
        resources :subjects
        resources :courses
      end
    end

    namespace :v2 do
      resources :users, only: %i[update show] do
        resources :providers

        patch :accept_transition_screen, on: :member
        patch :accept_rollover_screen, on: :member
        patch :accept_terms, on: :member
      end
      get 'providers/suggest', to: 'providers#suggest'
      get '/recruitment_cycles/:recruitment_cycle_year/providers/suggest', to: 'providers#suggest'

      concern :provider_routes do
        post :sync_courses_with_search_and_compare, on: :member
        resources :courses, param: :code do
          post :sync_with_search_and_compare, on: :member
          post :publish, on: :member
          post :publishable, on: :member
          get :new, on: :new
        end
        resources :sites, only: %i[index update show create]
        resources :recruitment_cycles, only: %i[index]
        post :sync_courses_with_search_and_compare, on: :member
      end

      resources :providers,
                param: :code,
                concerns: :provider_routes do
        resources :recruitment_cycles, only: :index
      end

      resources :recruitment_cycles,
                only: %i[index show],
                param: :year do
        resources :providers,
                  only: %i[index show update],
                  param: :code,
                  concerns: :provider_routes do
          post :publish, on: :member
          post :publishable, on: :member
        end
      end

      resource :sessions
      resources :site_statuses, only: :update

      resources :access_requests, only: %i[update index create show] do
        post :approve, on: :member
      end

      get 'build_new_course', to: 'courses#build_new'
    end

    namespace :system do
      post :sync, to: 'force_sync#sync'
    end
  end

  get 'error_500', to: 'error#error_500'
  get 'error_nodb', to: 'error#error_nodb'
end
# rubocop:enable Metrics/BlockLength
