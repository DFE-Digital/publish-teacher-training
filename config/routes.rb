# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

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
      resources :user_notification_preferences, only: %i[show update]

      resources :users, only: %i[update show] do
        resources :providers
        patch :accept_terms, on: :member
        patch :generate_and_send_magic_link, on: :collection
      end

      get "providers/suggest", to: "providers#suggest"
      get "providers/suggest_any", to: "providers#suggest_any"
      get "/recruitment_cycles/:recruitment_cycle_year/providers/suggest", to: "providers#suggest"

      resources :organisations, only: :index

      concern :provider_routes do
        resources :courses, param: :code do
          post :publish, on: :member
          post :publishable, on: :member
          post :withdraw, on: :member
          post :send_vacancies_filled_notification, on: :member
          get :new, on: :new
        end
        resources :sites, only: %i[index update show create]
        resources :recruitment_cycles, only: %i[index]
        get "training_providers/:training_provider_code", to: "accredited_provider_training_providers#show"
        get :training_providers, to: "accredited_provider_training_providers#index"
        get "/training_providers/:training_provider_code/courses", to: "accredited_body_training_provider_courses#index"
      end

      resources :providers,
                param: :code,
                concerns: :provider_routes do
        resources :recruitment_cycles, only: :index
        resources :allocations, only: %i[create index]
      end

      resources :allocations, only: %i[show update destroy]

      resources :recruitment_cycles,
                only: %i[index show],
                param: :year do
        resources :organisations, only: :index
        resources :providers,
                  only: %i[index show update],
                  param: :code,
                  concerns: :provider_routes do
          member do
            get :show_any
          end
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
        resources :recruitment_cycles, param: :year, only: [:show] do
          resources :providers, only: %i[index show] do
            resources :courses, only: %i[index show] do
              resources :locations, only: [:index]
            end
          end
        end
      end
    end
  end

  get "error_500", to: "error#error_500"
  get "error_nodb", to: "error#error_nodb"
end
# rubocop:enable Metrics/BlockLength
