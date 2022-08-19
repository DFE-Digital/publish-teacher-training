mount OpenApi::Rswag::Ui::Engine => "/api-docs"
mount OpenApi::Rswag::Api::Engine => "/api-docs"

namespace :api do
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
    get "training_providers/:training_provider_code", to: "accredited_provider_training_providers#show"
    get :training_providers, to: "accredited_provider_training_providers#index"
    get "/training_providers/:training_provider_code/courses", to: "accredited_body_training_provider_courses#index"
  end

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
