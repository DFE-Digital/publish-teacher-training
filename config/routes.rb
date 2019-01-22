# == Route Map
#
#           Prefix Verb   URI Pattern                       Controller#Action
# api_v1_providers GET    /api/v1/providers(.:format)       api/v1/providers#index
#                  POST   /api/v1/providers(.:format)       api/v1/providers#create
#  api_v1_provider GET    /api/v1/providers/:id(.:format)   api/v1/providers#show
#                  PATCH  /api/v1/providers/:id(.:format)   api/v1/providers#update
#                  PUT    /api/v1/providers/:id(.:format)   api/v1/providers#update
#                  DELETE /api/v1/providers/:id(.:format)   api/v1/providers#destroy
#  api_v1_subjects GET    /api/v1/subjects(.:format)        api/v1/subjects#index
#                  POST   /api/v1/subjects(.:format)        api/v1/subjects#create
#   api_v1_subject GET    /api/v1/subjects/:id(.:format)    api/v1/subjects#show
#                  PATCH  /api/v1/subjects/:id(.:format)    api/v1/subjects#update
#                  PUT    /api/v1/subjects/:id(.:format)    api/v1/subjects#update
#                  DELETE /api/v1/subjects/:id(.:format)    api/v1/subjects#destroy
#   api_v1_courses GET    /api/v1/courses(.:format)         api/v1/courses#index
#                  POST   /api/v1/courses(.:format)         api/v1/courses#create
#    api_v1_course GET    /api/v1/courses/:id(.:format)     api/v1/courses#show
#                  PATCH  /api/v1/courses/:id(.:format)     api/v1/courses#update
#                  PUT    /api/v1/courses/:id(.:format)     api/v1/courses#update
#                  DELETE /api/v1/courses/:id(.:format)     api/v1/courses#destroy
#           api_v1 GET    /api/v1/:year/courses(.:format)   api/v1/courses#show {:year=>/(2019|2020)/}
#                  GET    /api/v1/:year/subjects(.:format)  api/v1/subjects#show {:year=>/(2019|2020)/}
#                  GET    /api/v1/:year/providers(.:format) api/v1/providers#show {:year=>/(2019|2020)/}


Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :providers
      resources :subjects
      resources :courses
      scope "/(:recruitment_cycle_year)", constraints: { recruitment_cycle_year: /(2018|2019|2020)/ } do
        get '/courses', to: 'courses#index'
        get '/subjects', to: 'subjects#index'
        get '/providers', to: 'providers#index'
      end
    end
  end
end
