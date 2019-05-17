# == Route Map
#
#                Prefix Verb   URI Pattern                                              Controller#Action
#      api_v1_providers GET    /api/v1(/:recruitment_year)/providers(.:format)          api/v1/providers#index
#                       POST   /api/v1(/:recruitment_year)/providers(.:format)          api/v1/providers#create
#       api_v1_provider GET    /api/v1(/:recruitment_year)/providers/:id(.:format)      api/v1/providers#show
#                       PATCH  /api/v1(/:recruitment_year)/providers/:id(.:format)      api/v1/providers#update
#                       PUT    /api/v1(/:recruitment_year)/providers/:id(.:format)      api/v1/providers#update
#                       DELETE /api/v1(/:recruitment_year)/providers/:id(.:format)      api/v1/providers#destroy
#       api_v1_subjects GET    /api/v1(/:recruitment_year)/subjects(.:format)           api/v1/subjects#index
#                       POST   /api/v1(/:recruitment_year)/subjects(.:format)           api/v1/subjects#create
#        api_v1_subject GET    /api/v1(/:recruitment_year)/subjects/:id(.:format)       api/v1/subjects#show
#                       PATCH  /api/v1(/:recruitment_year)/subjects/:id(.:format)       api/v1/subjects#update
#                       PUT    /api/v1(/:recruitment_year)/subjects/:id(.:format)       api/v1/subjects#update
#                       DELETE /api/v1(/:recruitment_year)/subjects/:id(.:format)       api/v1/subjects#destroy
#        api_v1_courses GET    /api/v1(/:recruitment_year)/courses(.:format)            api/v1/courses#index
#                       POST   /api/v1(/:recruitment_year)/courses(.:format)            api/v1/courses#create
#         api_v1_course GET    /api/v1(/:recruitment_year)/courses/:id(.:format)        api/v1/courses#show
#                       PATCH  /api/v1(/:recruitment_year)/courses/:id(.:format)        api/v1/courses#update
#                       PUT    /api/v1(/:recruitment_year)/courses/:id(.:format)        api/v1/courses#update
#                       DELETE /api/v1(/:recruitment_year)/courses/:id(.:format)        api/v1/courses#destroy
#      api_v2_providers GET    /api/v2/providers(.:format)                              api/v2/providers#index
#                       POST   /api/v2/providers(.:format)                              api/v2/providers#create
#       api_v2_provider GET    /api/v2/providers/:id(.:format)                          api/v2/providers#show
#                       PATCH  /api/v2/providers/:id(.:format)                          api/v2/providers#update
#                       PUT    /api/v2/providers/:id(.:format)                          api/v2/providers#update
#                       DELETE /api/v2/providers/:id(.:format)                          api/v2/providers#destroy
# api_v2_user_providers GET    /api/v2/users/:user_id/providers(.:format)               api/v2/providers#index
#                       POST   /api/v2/users/:user_id/providers(.:format)               api/v2/providers#create
#  api_v2_user_provider GET    /api/v2/users/:user_id/providers/:id(.:format)           api/v2/providers#show
#                       PATCH  /api/v2/users/:user_id/providers/:id(.:format)           api/v2/providers#update
#                       PUT    /api/v2/users/:user_id/providers/:id(.:format)           api/v2/providers#update
#                       DELETE /api/v2/users/:user_id/providers/:id(.:format)           api/v2/providers#destroy
#          api_v2_users GET    /api/v2/users(.:format)                                  api/v2/users#index
#                       POST   /api/v2/users(.:format)                                  api/v2/users#create
#           api_v2_user GET    /api/v2/users/:id(.:format)                              api/v2/users#show
#                       PATCH  /api/v2/users/:id(.:format)                              api/v2/users#update
#                       PUT    /api/v2/users/:id(.:format)                              api/v2/users#update
#                       DELETE /api/v2/users/:id(.:format)                              api/v2/users#destroy
#        api_v2_courses GET    /api/v2/providers(/:provider_code)/courses(.:format)     api/v2/courses#index
#                       POST   /api/v2/providers(/:provider_code)/courses(.:format)     api/v2/courses#create
#         api_v2_course GET    /api/v2/providers(/:provider_code)/courses/:id(.:format) api/v2/courses#show
#                       PATCH  /api/v2/providers(/:provider_code)/courses/:id(.:format) api/v2/courses#update
#                       PUT    /api/v2/providers(/:provider_code)/courses/:id(.:format) api/v2/courses#update
#                       DELETE /api/v2/providers(/:provider_code)/courses/:id(.:format) api/v2/courses#destroy
#             error_500 GET    /error_500(.:format)                                     error#error_500
#            error_nodb GET    /error_nodb(.:format)                                    error#error_nodb

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
      end

      resources :providers, param: :code do
        resources :courses, param: :code, only: %i[index create show] do
          post :sync_with_search_and_compare, on: :member
          post :publish, on: :member
        end
        resources :sites, only: %i[index update show create]
      end

      resource :sessions
      resources :site_statuses, only: :update

      resources :access_requests, only: %i[update index create] do
        post :approve, on: :member
      end
    end
  end

  get 'error_500', to: 'error#error_500'
  get 'error_nodb', to: 'error#error_nodb'
end
# rubocop:enable Metrics/BlockLength
