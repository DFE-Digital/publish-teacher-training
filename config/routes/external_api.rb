# frozen_string_literal: true

get "/", to: redirect("/docs/")

mount OpenApi::Rswag::Ui::Engine => "/api-docs"
mount OpenApi::Rswag::Api::Engine => "/api-docs"

namespace :api do
  namespace :public do
    namespace :v1 do
      resources :recruitment_cycles, param: :year, only: [:show] do
        resources :courses, only: %i[index]
        resources :providers, only: %i[index show], param: :code do
          scope module: :providers do
            resources :locations, only: [:index]

            resources :courses, only: %i[index show], param: :code do
              resources :locations, only: [:index], module: :courses
            end
          end
        end
      end

      resources :subjects, only: %i[index]
      resources :subject_areas, only: :index

      get "provider_suggestions", to: "provider_suggestions#index"
      get "/courses", to: "courses#index"
    end
  end
end

get "error_500", to: "api_error#error500"
get "error_nodb", to: "api_error#error_nodb"
