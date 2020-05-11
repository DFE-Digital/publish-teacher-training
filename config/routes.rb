# == Route Map
#
#                                               Prefix Verb   URI Pattern                                                                                                                              Controller#Action
#                                                 ping GET    /ping(.:format)                                                                                                                          heartbeat#ping
#                                          healthcheck GET    /healthcheck(.:format)                                                                                                                   heartbeat#healthcheck
#                                    open_api_rswag_ui        /api-docs                                                                                                                                OpenApi::Rswag::Ui::Engine
#                                   open_api_rswag_api        /api-docs                                                                                                                                OpenApi::Rswag::Api::Engine
#                                     api_v1_providers GET    /api/v1(/:recruitment_year)/providers(.:format)                                                                                          api/v1/providers#index {:recruitment_year=>/2020|2021/}
#                                      api_v1_subjects GET    /api/v1(/:recruitment_year)/subjects(.:format)                                                                                           api/v1/subjects#index {:recruitment_year=>/2020|2021/}
#                                       api_v1_courses GET    /api/v1(/:recruitment_year)/courses(.:format)                                                                                            api/v1/courses#index {:recruitment_year=>/2020|2021/}
#                            api_v2_user_notifications GET    /api/v2/users/:user_id/notifications(.:format)                                                                                           api/v2/notifications#index
#                                                      POST   /api/v2/users/:user_id/notifications(.:format)                                                                                           api/v2/notifications#create
#                                api_v2_user_providers GET    /api/v2/users/:user_id/providers(.:format)                                                                                               api/v2/providers#index
#                                                      POST   /api/v2/users/:user_id/providers(.:format)                                                                                               api/v2/providers#create
#                                 api_v2_user_provider GET    /api/v2/users/:user_id/providers/:id(.:format)                                                                                           api/v2/providers#show
#                                                      PATCH  /api/v2/users/:user_id/providers/:id(.:format)                                                                                           api/v2/providers#update
#                                                      PUT    /api/v2/users/:user_id/providers/:id(.:format)                                                                                           api/v2/providers#update
#                                                      DELETE /api/v2/users/:user_id/providers/:id(.:format)                                                                                           api/v2/providers#destroy
#                 accept_transition_screen_api_v2_user PATCH  /api/v2/users/:id/accept_transition_screen(.:format)                                                                                     api/v2/users#accept_transition_screen
#                   accept_rollover_screen_api_v2_user PATCH  /api/v2/users/:id/accept_rollover_screen(.:format)                                                                                       api/v2/users#accept_rollover_screen
#                             accept_terms_api_v2_user PATCH  /api/v2/users/:id/accept_terms(.:format)                                                                                                 api/v2/users#accept_terms
#            generate_and_send_magic_link_api_v2_users PATCH  /api/v2/users/generate_and_send_magic_link(.:format)                                                                                     api/v2/users#generate_and_send_magic_link
#                                          api_v2_user GET    /api/v2/users/:id(.:format)                                                                                                              api/v2/users#show
#                                                      PATCH  /api/v2/users/:id(.:format)                                                                                                              api/v2/users#update
#                                                      PUT    /api/v2/users/:id(.:format)                                                                                                              api/v2/users#update
#                             api_v2_providers_suggest GET    /api/v2/providers/suggest(.:format)                                                                                                      api/v2/providers#suggest
#                                               api_v2 GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/suggest(.:format)                                                           api/v2/providers#suggest
#                                 api_v2_organisations GET    /api/v2/organisations(.:format)                                                                                                          api/v2/organisations#index
#                   api_v2_provider_recruitment_cycles GET    /api/v2/providers/:provider_code/recruitment_cycles(.:format)                                                                            api/v2/recruitment_cycles#index
#                          api_v2_provider_allocations GET    /api/v2/providers/:provider_code/allocations(.:format)                                                                                   api/v2/allocations#index
#                                                      POST   /api/v2/providers/:provider_code/allocations(.:format)                                                                                   api/v2/allocations#create
#                       publish_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/publish(.:format)                                                                         api/v2/courses#publish
#                   publishable_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/publishable(.:format)                                                                     api/v2/courses#publishable
#                      withdraw_api_v2_provider_course POST   /api/v2/providers/:provider_code/courses/:code/withdraw(.:format)                                                                        api/v2/courses#withdraw
#                           new_api_v2_provider_course GET    /api/v2/providers/:provider_code/courses/new(.:format)                                                                                   api/v2/courses#new
#                              api_v2_provider_courses GET    /api/v2/providers/:provider_code/courses(.:format)                                                                                       api/v2/courses#index
#                                                      POST   /api/v2/providers/:provider_code/courses(.:format)                                                                                       api/v2/courses#create
#                               api_v2_provider_course GET    /api/v2/providers/:provider_code/courses/:code(.:format)                                                                                 api/v2/courses#show
#                                                      PATCH  /api/v2/providers/:provider_code/courses/:code(.:format)                                                                                 api/v2/courses#update
#                                                      PUT    /api/v2/providers/:provider_code/courses/:code(.:format)                                                                                 api/v2/courses#update
#                                                      DELETE /api/v2/providers/:provider_code/courses/:code(.:format)                                                                                 api/v2/courses#destroy
#                                api_v2_provider_sites GET    /api/v2/providers/:provider_code/sites(.:format)                                                                                         api/v2/sites#index
#                                                      POST   /api/v2/providers/:provider_code/sites(.:format)                                                                                         api/v2/sites#create
#                                 api_v2_provider_site GET    /api/v2/providers/:provider_code/sites/:id(.:format)                                                                                     api/v2/sites#show
#                                                      PATCH  /api/v2/providers/:provider_code/sites/:id(.:format)                                                                                     api/v2/sites#update
#                                                      PUT    /api/v2/providers/:provider_code/sites/:id(.:format)                                                                                     api/v2/sites#update
#                                                      GET    /api/v2/providers/:provider_code/recruitment_cycles(.:format)                                                                            api/v2/recruitment_cycles#index
#                   api_v2_provider_training_providers GET    /api/v2/providers/:provider_code/training_providers(.:format)                                                                            api/v2/accredited_provider_training_providers#index
#                                                      GET    /api/v2/providers/:provider_code/training_providers/:training_provider_code/courses(.:format)                                            api/v2/accredited_body_training_provider_courses#index
#                                     api_v2_providers GET    /api/v2/providers(.:format)                                                                                                              api/v2/providers#index
#                                                      POST   /api/v2/providers(.:format)                                                                                                              api/v2/providers#create
#                                      api_v2_provider GET    /api/v2/providers/:code(.:format)                                                                                                        api/v2/providers#show
#                                                      PATCH  /api/v2/providers/:code(.:format)                                                                                                        api/v2/providers#update
#                                                      PUT    /api/v2/providers/:code(.:format)                                                                                                        api/v2/providers#update
#                                                      DELETE /api/v2/providers/:code(.:format)                                                                                                        api/v2/providers#destroy
#                                    api_v2_allocation GET    /api/v2/allocations/:id(.:format)                                                                                                        api/v2/allocations#show
#                                                      PATCH  /api/v2/allocations/:id(.:format)                                                                                                        api/v2/allocations#update
#                                                      PUT    /api/v2/allocations/:id(.:format)                                                                                                        api/v2/allocations#update
#               api_v2_recruitment_cycle_organisations GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/organisations(.:format)                                                               api/v2/organisations#index
#     publish_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/publish(.:format)                              api/v2/courses#publish
# publishable_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/publishable(.:format)                          api/v2/courses#publishable
#    withdraw_api_v2_recruitment_cycle_provider_course POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code/withdraw(.:format)                             api/v2/courses#withdraw
#         new_api_v2_recruitment_cycle_provider_course GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/new(.:format)                                        api/v2/courses#new
#            api_v2_recruitment_cycle_provider_courses GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses(.:format)                                            api/v2/courses#index
#                                                      POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses(.:format)                                            api/v2/courses#create
#             api_v2_recruitment_cycle_provider_course GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                                      api/v2/courses#show
#                                                      PATCH  /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                                      api/v2/courses#update
#                                                      PUT    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                                      api/v2/courses#update
#                                                      DELETE /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                                      api/v2/courses#destroy
#              api_v2_recruitment_cycle_provider_sites GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites(.:format)                                              api/v2/sites#index
#                                                      POST   /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites(.:format)                                              api/v2/sites#create
#               api_v2_recruitment_cycle_provider_site GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                          api/v2/sites#show
#                                                      PATCH  /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                          api/v2/sites#update
#                                                      PUT    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/sites/:id(.:format)                                          api/v2/sites#update
# api_v2_recruitment_cycle_provider_recruitment_cycles GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/recruitment_cycles(.:format)                                 api/v2/recruitment_cycles#index
# api_v2_recruitment_cycle_provider_training_providers GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/training_providers(.:format)                                 api/v2/accredited_provider_training_providers#index
#                                                      GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/training_providers/:training_provider_code/courses(.:format) api/v2/accredited_body_training_provider_courses#index
#                   api_v2_recruitment_cycle_providers GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers(.:format)                                                                   api/v2/providers#index
#                    api_v2_recruitment_cycle_provider GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                             api/v2/providers#show
#                                                      PATCH  /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                             api/v2/providers#update
#                                                      PUT    /api/v2/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                             api/v2/providers#update
#                     api_v2_recruitment_cycle_courses GET    /api/v2/recruitment_cycles/:recruitment_cycle_year/courses(.:format)                                                                     api/v2/courses#index
#                            api_v2_recruitment_cycles GET    /api/v2/recruitment_cycles(.:format)                                                                                                     api/v2/recruitment_cycles#index
#                             api_v2_recruitment_cycle GET    /api/v2/recruitment_cycles/:year(.:format)                                                                                               api/v2/recruitment_cycles#show
#                      create_by_magic_api_v2_sessions PATCH  /api/v2/sessions/create_by_magic(.:format)                                                                                               api/v2/sessions#create_by_magic
#                                      api_v2_sessions GET    /api/v2/sessions(.:format)                                                                                                               api/v2/sessions#show
#                                                      PATCH  /api/v2/sessions(.:format)                                                                                                               api/v2/sessions#update
#                                                      PUT    /api/v2/sessions(.:format)                                                                                                               api/v2/sessions#update
#                                                      DELETE /api/v2/sessions(.:format)                                                                                                               api/v2/sessions#destroy
#                                                      POST   /api/v2/sessions(.:format)                                                                                                               api/v2/sessions#create
#                                   api_v2_site_status PATCH  /api/v2/site_statuses/:id(.:format)                                                                                                      api/v2/site_statuses#update
#                                                      PUT    /api/v2/site_statuses/:id(.:format)                                                                                                      api/v2/site_statuses#update
#                        approve_api_v2_access_request POST   /api/v2/access_requests/:id/approve(.:format)                                                                                            api/v2/access_requests#approve
#                               api_v2_access_requests GET    /api/v2/access_requests(.:format)                                                                                                        api/v2/access_requests#index
#                                                      POST   /api/v2/access_requests(.:format)                                                                                                        api/v2/access_requests#create
#                                api_v2_access_request GET    /api/v2/access_requests/:id(.:format)                                                                                                    api/v2/access_requests#show
#                                                      PATCH  /api/v2/access_requests/:id(.:format)                                                                                                    api/v2/access_requests#update
#                                                      PUT    /api/v2/access_requests/:id(.:format)                                                                                                    api/v2/access_requests#update
#                                                      DELETE /api/v2/access_requests/:id(.:format)                                                                                                    api/v2/access_requests#destroy
#                              api_v2_build_new_course GET    /api/v2/build_new_course(.:format)                                                                                                       api/v2/courses#build_new
#                                 api_v3_subject_areas GET    /api/v3/subject_areas(.:format)                                                                                                          api/v3/subject_areas#index
#                                      api_v3_subjects GET    /api/v3/subjects(.:format)                                                                                                               api/v3/subjects#index
#                                       api_v3_courses GET    /api/v3/courses(.:format)                                                                                                                api/v3/courses#index
#                     api_v3_recruitment_cycle_courses GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/courses(.:format)                                                                     api/v3/courses#index
#            api_v3_recruitment_cycle_provider_courses GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses(.:format)                                            api/v3/courses#index
#             api_v3_recruitment_cycle_provider_course GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:code(.:format)                                      api/v3/courses#show
#                   api_v3_recruitment_cycle_providers GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/providers(.:format)                                                                   api/v3/providers#index
#                    api_v3_recruitment_cycle_provider GET    /api/v3/recruitment_cycles/:recruitment_cycle_year/providers/:code(.:format)                                                             api/v3/providers#show
#                             api_v3_recruitment_cycle GET    /api/v3/recruitment_cycles/:year(.:format)                                                                                               api/v3/recruitment_cycles#show
#                          api_v3_provider_suggestions GET    /api/v3/provider-suggestions(.:format)                                                                                                   api/v3/provider_suggestions#index
#                       api_public_v1_course_locations GET    /api/public/v1/courses/:course_id/locations(.:format)                                                                                    api/public/v1/locations#index
#                                api_public_v1_courses GET    /api/public/v1/courses(.:format)                                                                                                         api/public/v1/courses#index
#                                            error_500 GET    /error_500(.:format)                                                                                                                     error#error_500
#                                           error_nodb GET    /error_nodb(.:format)                                                                                                                    error#error_nodb
#
# Routes for OpenApi::Rswag::Ui::Engine:
#
#
# Routes for OpenApi::Rswag::Api::Engine:

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat

  mount OpenApi::Rswag::Ui::Engine => "/api-docs"
  mount OpenApi::Rswag::Api::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      scope "/(:recruitment_year)", constraints: { recruitment_year: /2020|2021/ } do
        resources :providers, only: :index
        resources :subjects, only: :index
        resources :courses, only: :index
      end
    end

    namespace :v2 do
      resources :users, only: %i[update show] do
        resources :notifications, only: %i[create index]
        resources :providers

        patch :accept_transition_screen, on: :member
        patch :accept_rollover_screen, on: :member
        patch :accept_terms, on: :member

        patch :generate_and_send_magic_link, on: :collection
      end

      get "providers/suggest", to: "providers#suggest"
      get "/recruitment_cycles/:recruitment_cycle_year/providers/suggest", to: "providers#suggest"

      resources :organisations, only: :index

      concern :provider_routes do
        resources :courses, param: :code do
          post :publish, on: :member
          post :publishable, on: :member
          post :withdraw, on: :member
          get :new, on: :new
        end
        resources :sites, only: %i[index update show create]
        resources :recruitment_cycles, only: %i[index]
        get :training_providers, to: "accredited_provider_training_providers#index"
        get "/training_providers/:training_provider_code/courses", to: "accredited_body_training_provider_courses#index"
      end

      resources :providers,
                param: :code,
                concerns: :provider_routes do
        resources :recruitment_cycles, only: :index
        resources :allocations, only: %i[create index]
      end

      resources :allocations, only: %i(show update)

      resources :recruitment_cycles,
                only: %i[index show],
                param: :year do
        resources :organisations, only: :index
        resources :providers,
                  only: %i[index show update],
                  param: :code,
                  concerns: :provider_routes do
        end

        get "/courses", to: "courses#index"
      end

      resource :sessions do
        patch :create_by_magic
      end

      resources :site_statuses, only: :update

      resources :access_requests, except: :edit do
        post :approve, on: :member
      end

      get "build_new_course", to: "courses#build_new"
    end

    namespace :v3 do
      resources :subject_areas, only: :index
      resources :subjects, only: :index

      resources :courses, only: :index
      resources :recruitment_cycles, only: :show, param: :year do
        resources :courses, only: :index
        resources :providers, only: %i[index show], param: :code do
          resources :courses, only: %i[index show], param: :code
        end
      end
      get "provider-suggestions", to: "provider_suggestions#index"
    end

    namespace :public do
      namespace :v1 do
        resources :courses, only: [:index] do
          resources :locations, only: [:index]
        end
      end
    end
  end

  get "error_500", to: "error#error_500"
  get "error_nodb", to: "error#error_nodb"
end
# rubocop:enable Metrics/BlockLength
