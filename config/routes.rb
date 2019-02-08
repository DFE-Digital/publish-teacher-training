# == Route Map
#
#               Prefix Verb   URI Pattern                                         Controller#Action
#     api_v1_providers GET    /api/v1(/:recruitment_year)/providers(.:format)     api/v1/providers#index
#                      POST   /api/v1(/:recruitment_year)/providers(.:format)     api/v1/providers#create
#      api_v1_provider GET    /api/v1(/:recruitment_year)/providers/:id(.:format) api/v1/providers#show
#                      PATCH  /api/v1(/:recruitment_year)/providers/:id(.:format) api/v1/providers#update
#                      PUT    /api/v1(/:recruitment_year)/providers/:id(.:format) api/v1/providers#update
#                      DELETE /api/v1(/:recruitment_year)/providers/:id(.:format) api/v1/providers#destroy
#      api_v1_subjects GET    /api/v1(/:recruitment_year)/subjects(.:format)      api/v1/subjects#index
#                      POST   /api/v1(/:recruitment_year)/subjects(.:format)      api/v1/subjects#create
#       api_v1_subject GET    /api/v1(/:recruitment_year)/subjects/:id(.:format)  api/v1/subjects#show
#                      PATCH  /api/v1(/:recruitment_year)/subjects/:id(.:format)  api/v1/subjects#update
#                      PUT    /api/v1(/:recruitment_year)/subjects/:id(.:format)  api/v1/subjects#update
#                      DELETE /api/v1(/:recruitment_year)/subjects/:id(.:format)  api/v1/subjects#destroy
#       api_v1_courses GET    /api/v1(/:recruitment_year)/courses(.:format)       api/v1/courses#index
#                      POST   /api/v1(/:recruitment_year)/courses(.:format)       api/v1/courses#create
#        api_v1_course GET    /api/v1(/:recruitment_year)/courses/:id(.:format)   api/v1/courses#show
#                      PATCH  /api/v1(/:recruitment_year)/courses/:id(.:format)   api/v1/courses#update
#                      PUT    /api/v1(/:recruitment_year)/courses/:id(.:format)   api/v1/courses#update
#                      DELETE /api/v1(/:recruitment_year)/courses/:id(.:format)   api/v1/courses#destroy
#     api_v2_providers GET    /api/v2/providers(.:format)                         api/v2/providers#index
#                      POST   /api/v2/providers(.:format)                         api/v2/providers#create
#      api_v2_provider GET    /api/v2/providers/:id(.:format)                     api/v2/providers#show
#                      PATCH  /api/v2/providers/:id(.:format)                     api/v2/providers#update
#                      PUT    /api/v2/providers/:id(.:format)                     api/v2/providers#update
#                      DELETE /api/v2/providers/:id(.:format)                     api/v2/providers#destroy
#      api_v2_subjects GET    /api/v2/subjects(.:format)                          api/v2/subjects#index
#                      POST   /api/v2/subjects(.:format)                          api/v2/subjects#create
#       api_v2_subject GET    /api/v2/subjects/:id(.:format)                      api/v2/subjects#show
#                      PATCH  /api/v2/subjects/:id(.:format)                      api/v2/subjects#update
#                      PUT    /api/v2/subjects/:id(.:format)                      api/v2/subjects#update
#                      DELETE /api/v2/subjects/:id(.:format)                      api/v2/subjects#destroy
#       api_v2_courses GET    /api/v2/courses(.:format)                           api/v2/courses#index
#                      POST   /api/v2/courses(.:format)                           api/v2/courses#create
#        api_v2_course GET    /api/v2/courses/:id(.:format)                       api/v2/courses#show
#                      PATCH  /api/v2/courses/:id(.:format)                       api/v2/courses#update
#                      PUT    /api/v2/courses/:id(.:format)                       api/v2/courses#update
#                      DELETE /api/v2/courses/:id(.:format)                       api/v2/courses#destroy
# api_v2_organisations GET    /api/v2/organisations(.:format)                     api/v2/organisations#index
#                      POST   /api/v2/organisations(.:format)                     api/v2/organisations#create
#  api_v2_organisation GET    /api/v2/organisations/:id(.:format)                 api/v2/organisations#show
#                      PATCH  /api/v2/organisations/:id(.:format)                 api/v2/organisations#update
#                      PUT    /api/v2/organisations/:id(.:format)                 api/v2/organisations#update
#                      DELETE /api/v2/organisations/:id(.:format)                 api/v2/organisations#destroy
#            error_500 GET    /error_500(.:format)                                error#error_500

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
      resources :providers
      resources :subjects
      resources :courses
      resources :organisations
    end
  end

  get 'error_500', to: 'error#error_500'
end
