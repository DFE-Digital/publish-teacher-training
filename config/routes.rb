# == Route Map
#
#                                                                 Prefix Verb   URI Pattern                                                                                                                      Controller#Action
#                                                                   ping GET    /ping(.:format)                                                                                                                  health_checks#ping
#                                                       api_v1_providers GET    /api/v1(/:recruitment_year)/providers(.:format)                                                                                  api/v1/providers#index {:recruitment_year=>/2020|2021/}
#                                                                        POST   /api/v1(/:recruitment_year)/providers(.:format)                                                                                  api/v1/providers#create {:recruitment_year=>/2020|2021/}
#                                                        api_v1_provider GET    /api/v1(/:recruitment_year)/providers/:id(.:format)                                                                              api/v1/providers#show {:recruitment_year=>/2020|2021/}
#                                                                        PATCH  /api/v1(/:recruitment_year)/providers/:id(.:format)                                                                              api/v1/providers#update {:recruitment_year=>/2020|2021/}
#                                                                        PUT    /api/v1(/:recruitment_year)/providers/:id(.:format)                                                                              api/v1/providers#update {:recruitment_year=>/2020|2021/}
#                                                                        DELETE /api/v1(/:recruitment_year)/providers/:id(.:format)                                                                              api/v1/providers#destroy {:recruitment_year=>/2020|2021/}
#                                                        api_v1_subjects GET    /api/v1(/:recruitment_year)/subjects(.:format)                                                                                   api/v1/subjects#index {:recruitment_year=>/2020|2021/}
#                                                                        POST   /api/v1(/:recruitment_year)/subjects(.:format)                                                                                   api/v1/subjects#create {:recruitment_year=>/2020|2021/}
#                                                         api_v1_subject GET    /api/v1(/:recruitment_year)/subjects/:id(.:format)                                                                               api/v1/subjects#show {:recruitment_year=>/2020|2021/}
#                                                                        PATCH  /api/v1(/:recruitment_year)/subjects/:id(.:format)                                                                               api/v1/subjects#update {:recruitment_year=>/2020|2021/}
#                                                                        PUT    /api/v1(/:recruitment_year)/subjects/:id(.:format)                                                                               api/v1/subjects#update {:recruitment_year=>/2020|2021/}
#                                                                        DELETE /api/v1(/:recruitment_year)/subjects/:id(.:format)                                                                               api/v1/subjects#destroy {:recruitment_year=>/2020|2021/}
#                                                         api_v1_courses GET    /api/v1(/:recruitment_year)/courses(.:format)                                                                                    api/v1/courses#index {:recruitment_year=>/2020|2021/}
#                                                                        POST   /api/v1(/:recruitment_year)/courses(.:format)                                                                                    api/v1/courses#create {:recruitment_year=>/2020|2021/}
#                                                          api_v1_course GET    /api/v1(/:recruitment_year)/courses/:id(.:format)                                                                                api/v1/courses#show {:recruitment_year=>/2020|2021/}
#                                                                        PATCH  /api/v1(/:recruitment_year)/courses/:id(.:format)                                                                                api/v1/courses#update {:recruitment_year=>/2020|2021/}
#                                                                        PUT    /api/v1(/:recruitment_year)/courses/:id(.:format)                                                                                api/v1/courses#update {:recruitment_year=>/2020|2021/}
#                                                                        DELETE /api/v1(/:recruitment_year)/courses/:id(.:format)                                                                                api/v1/courses#destroy {:recruitment_year=>/2020|2021/}
#                                                  api_v2_user_providers GET    /api/v2/users/:user_id/providers(.:format)                                                                                       api/v2/providers#index
#                                                                        POST   /api/v2/users/:user_id/providers(.:format)                                                                                       api/v2/providers#create
#                                                   api_v2_user_provider GET    /api/v2/users/:user_id/providers/:id(.:format)                                                                                   api/v2/providers#show
#                                                                        PATCH  /api/v2/users/:user_id/providers/:id(.:format)                                                                                   api/v2/providers#update
#                                                                        PUT    /api/v2/users/:user_id/providers/:id(.:format)                                                                                   api/v2/providers#update
#                                                                        DELETE /api/v2/users/:user_id/providers/:id(.:format)                                                                                   api/v2/providers#destroy
#                                   accept_transition_screen_api_v2_user PATCH  /api/v2/users/:id/accept_transition_screen(.:format)                                                                             api/v2/users#accept_transition_screen
#                                     accept_rollover_screen_api_v2_user PATCH  /api/v2/users/:id/accept_rollover_screen(.:format)                                                                               api/v2/users#accept_rollover_screen
#                                               accept_terms_api_v2_user PATCH  /api/v2/users/:id/accept_terms(.:format)                                                                                         api/v2/users#accept_terms
#                                                            api_v2_user GET    /api/v2/users/:id(.:format)                                                                                                      api/v2/users#show
#                                                                        PATCH  /api/v2/users/:id(.:format)                                                                                                      api/v2/users#update
#                                                                        PUT    /api/v2/users/:id(.:format)                                                                                                      api/v2/users#update
#                                               api_v2_providers_suggest GET    /api/v2/providers/suggest(.:format)                                                                                              api/v2/providers#suggest
#                                                                 api_v2 GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/suggest(.:format)                                                   api/v2/providers#suggest
#                                     api_v2_provider_recruitment_cycles GET    /api/v2/providers/:provider_code/recruitment_cycles(.:format)                                                                    api/v2/recruitment_cycles#index
#                   sync_courses_with_search_and_compare_api_v2_provider POST   /api/v2/providers/:code/sync_courses_with_search_and_compare(.:format)                                                           api/v2/providers#sync_courses_with_search_and_compare
#                    sync_with_search_and_compare_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/sync_with_search_and_compare(.:format)                                            api/v2/courses#sync_with_search_and_compare
#                                         publish_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/publish(.:format)                                                                 api/v2/courses#publish
#                                     publishable_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/publishable(.:format)                                                             api/v2/courses#publishable
#                                        withdraw_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/withdraw(.:format)                                                                api/v2/courses#withdraw
#                                             new_api_v2_provider_course GET    /api/v2/providers/:provider_code/courses/new(.:format)                                                                           api/v2/courses#new
#                                                api_v2_provider_courses GET    /api/v2/providers/:provider_code/courses(.:format)                                                                               api/v2/courses#index
#                                                                        POST   /api/v2/providers/:provider_code/courses(.:format)                                                                               api/v2/courses#create
#                                                 api_v2_provider_course GET    /api/v2/providers/:provider_code/courses/:code(.:format)                                                                         api/v2/courses#show
#                                                                        PATCH  /api/v2/providers/:provider_code/courses/:code(.:format)                                                                         api/v2/courses#update
#                                                                        PUT    /api/v2/providers/:provider_code/courses/:code(.:format)                                                                         api/v2/courses#update
#                                                                        DELETE /api/v2/providers/:provider_code/courses/:code(.:format)                                                                         api/v2/courses#destroy
#                                                  api_v2_provider_sites GET    /api/v2/providers/:provider_code/sites(.:format)                                                                                 api/v2/sites#index
#                                                                        POST   /api/v2/providers/:provider_code/sites(.:format)                                                                                 api/v2/sites#create
#                                                   api_v2_provider_site GET    /api/v2/providers/:provider_code/sites/:id(.:format)                                                                             api/v2/sites#show
#                                                                        PATCH  /api/v2/providers/:provider_code/sites/:id(.:format)                                                                             api/v2/sites#update
#                                                                        PUT    /api/v2/providers/:provider_code/sites/:id(.:format)                                                                             api/v2/sites#update
#                                                                        GET    /api/v2/providers/:provider_code/recruitment_cycles(.:format)                                                                    api/v2/recruitment_cycles#index
#                                                                        POST   /api/v2/providers/:code/sync_courses_with_search_and_compare(.:format)                                                           api/v2/providers#sync_courses_with_search_and_compare
#                                                       api_v2_providers GET    /api/v2/providers(.:format)                                                                                                      api/v2/providers#index
#                                                                        POST   /api/v2/providers(.:format)                                                                                                      api/v2/providers#create
#                                                        api_v2_provider GET    /api/v2/providers/:code(.:format)                                                                                                api/v2/providers#show
#                                                                        PATCH  /api/v2/providers/:code(.:format)                                                                                                api/v2/providers#update
#                                                                        PUT    /api/v2/providers/:code(.:format)                                                                                                api/v2/providers#update
#                                                                        DELETE /api/v2/providers/:code(.:format)                                                                                                api/v2/providers#destroy
# sync_courses_with_search_and_compare_api_v2_recruitment_cycle_provider POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code/sync_courses_with_search_and_compare(.:format)                api/v2/providers#sync_courses_with_search_and_compare
#  sync_with_search_and_compare_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/sync_with_search_and_compare(.:format) api/v2/courses#sync_with_search_and_compare
#                       publish_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/publish(.:format)                      api/v2/courses#publish
#                   publishable_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/publishable(.:format)                  api/v2/courses#publishable
#                      withdraw_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/withdraw(.:format)                     api/v2/courses#withdraw
#                           new_api_v2_recruitment_cycle_provider_course GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/new(.:format)                                api/v2/courses#new
#                              api_v2_recruitment_cycle_provider_courses GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses(.:format)                                    api/v2/courses#index
#                                                                        POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses(.:format)                                    api/v2/courses#create
#                               api_v2_recruitment_cycle_provider_course GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                              api/v2/courses#show
#                                                                        PATCH  /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                              api/v2/courses#update
#                                                                        PUT    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                              api/v2/courses#update
#                                                                        DELETE /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                              api/v2/courses#destroy
#                                api_v2_recruitment_cycle_provider_sites GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites(.:format)                                      api/v2/sites#index
#                                                                        POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites(.:format)                                      api/v2/sites#create
#                                 api_v2_recruitment_cycle_provider_site GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                  api/v2/sites#show
#                                                                        PATCH  /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                  api/v2/sites#update
#                                                                        PUT    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                  api/v2/sites#update
#                   api_v2_recruitment_cycle_provider_recruitment_cycles GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/recruitment_cycles(.:format)                         api/v2/recruitment_cycles#index
#                                                                        POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code/sync_courses_with_search_and_compare(.:format)                api/v2/providers#sync_courses_with_search_and_compare
#                                     api_v2_recruitment_cycle_providers GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers(.:format)                                                           api/v2/providers#index
#                                      api_v2_recruitment_cycle_provider GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                     api/v2/providers#show
#                                                                        PATCH  /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                     api/v2/providers#update
#                                                                        PUT    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                     api/v2/providers#update
#                                              api_v2_recruitment_cycles GET    /api/v2/recruitment_cycles(.:format)                                                                                             api/v2/recruitment_cycles#index
#                                               api_v2_recruitment_cycle GET    /api/v2/recruitment_cycles/:year(.:format)                                                                                       api/v2/recruitment_cycles#show
#                                                        api_v2_sessions GET    /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#show
#                                                                        PATCH  /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#update
#                                                                        PUT    /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#update
#                                                                        DELETE /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#destroy
#                                                                        POST   /api/v2/sessions(.:format)                                                                                                       api/v2/sessions#create
#                                                     api_v2_site_status PATCH  /api/v2/site_statuses/:id(.:format)                                                                                              api/v2/site_statuses#update
#                                                                        PUT    /api/v2/site_statuses/:id(.:format)                                                                                              api/v2/site_statuses#update
#                                          approve_api_v2_access_request POST   /api/v2/access_requests/:id/approve(.:format)                                                                                    api/v2/access_requests#approve
#                                                 api_v2_access_requests GET    /api/v2/access_requests(.:format)                                                                                                api/v2/access_requests#index
#                                                                        POST   /api/v2/access_requests(.:format)                                                                                                api/v2/access_requests#create
#                                                  api_v2_access_request GET    /api/v2/access_requests/:id(.:format)                                                                                            api/v2/access_requests#show
#                                                                        PATCH  /api/v2/access_requests/:id(.:format)                                                                                            api/v2/access_requests#update
#                                                                        PUT    /api/v2/access_requests/:id(.:format)                                                                                            api/v2/access_requests#update
#                                                                        DELETE /api/v2/access_requests/:id(.:format)                                                                                            api/v2/access_requests#destroy
#                                                api_v2_build_new_course GET    /api/v2/build_new_course(.:format)                                                                                               api/v2/courses#build_new
#                              api_v3_recruitment_cycle_provider_courses GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses(.:format)                                    api/v3/courses#index
#                               api_v3_recruitment_cycle_provider_course GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                              api/v3/courses#show
#                                     api_v3_recruitment_cycle_providers GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/providers(.:format)                                                           api/v3/providers#index
#                                      api_v3_recruitment_cycle_provider GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                     api/v3/providers#show
#                                               api_v3_recruitment_cycle GET    /api/v3/recruitment_cycles/:year(.:format)                                                                                       api/v3/recruitment_cycles#show
#                                                        api_system_sync POST   /api/system/sync(.:format)                                                                                                       api/system/force_sync#sync
#                                                              error_500 GET    /error_500(.:format)                                                                                                             error#error_500
#                                                             error_nodb GET    /error_nodb(.:format)                                                                                                            error#error_nodb

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  get :ping, controller: :health_checks

  namespace :api do
    namespace :v1 do
      scope "/(:recruitment_year)", constraints: { recruitment_year: /2020|2021/ } do
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
      get "providers/suggest", to: "providers#suggest"
      get "/recruitment_cycles/:recruitment_cycle_year/providers/suggest", to: "providers#suggest"

      concern :provider_routes do
        post :sync_courses_with_search_and_compare, on: :member
        resources :courses, param: :code do
          post :sync_with_search_and_compare, on: :member
          post :publish, on: :member
          post :publishable, on: :member
          post :withdraw, on: :member
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
        end
      end

      resource :sessions
      resources :site_statuses, only: :update

      resources :access_requests, except: :edit do
        post :approve, on: :member
      end

      get "build_new_course", to: "courses#build_new"
    end

    namespace :v3 do
      resources :recruitment_cycles,
                only: :show,
                param: :year do
        resources :providers,
                  only: %i[index show],
                  param: :code do
          resources :courses,
                    only: %i[index show],
                    param: :code
        end
      end
    end

    namespace :system do
      post :sync, to: "force_sync#sync"
    end
  end

  get "error_500", to: "error#error_500"
  get "error_nodb", to: "error#error_nodb"
end
# rubocop:enable Metrics/BlockLength
