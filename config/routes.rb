Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  constraints(ApiConstraint.new) do
    get "/", to: redirect("/docs/")
  end

  root to: "publish/providers#index"

  mount OpenApi::Rswag::Ui::Engine => "/api-docs"
  mount OpenApi::Rswag::Api::Engine => "/api-docs"

  get "/sign-in", to: "sign_in#index"
  get "/user-not-found", to: "sign_in#new"
  get "/sign-out", to: "sessions#sign_out"

  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/cookies", to: "pages#cookies", as: :cookies
  get "/guidance", to: "pages#guidance", as: :guidance
  get "/performance-dashboard", to: "pages#performance_dashboard", as: :performance_dashboard
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/terms-conditions", to: "pages#terms", as: :terms

  if AuthenticationService.persona?
    get "/personas", to: "personas#index"
    post "/auth/developer/callback", to: "sessions#callback"
    get "/auth/developer/signout", to: "sessions#destroy"
  else
    get "/auth/dfe/callback", to: "sessions#callback"
    get "/auth/dfe/signout", to: "sessions#destroy"
  end

  scope via: :all do
    match "/404", to: "errors#not_found"
    match "/500", to: "errors#internal_server_error"
    match "/403", to: "errors#forbidden"
  end

  namespace :publish, as: :publish do
    get "/organisations", to: "providers#index", as: :root

    resources :providers, path: "organisations", param: :code, only: [] do
      get "/users", on: :member, to: "users#index"
      get "/request-access", on: :member, to: "providers/access_requests#new"
      post "/request-access", on: :member, to: "providers/access_requests#create"
      get "locations"

      resources :recruitment_cycles, param: :year, constraints: { year: /#{Settings.current_recruitment_cycle_year}|#{Settings.current_recruitment_cycle_year + 1}/ }, path: "", only: [:show] do
        get "/about", on: :member, to: "providers#about"
        put "/about", on: :member, to: "providers#update"
        get "/details", on: :member, to: "providers#details"

        resource :courses, only: %i[create] do
          resource :outcome, on: :member, only: %i[new], controller: "courses/outcome" do
            get "continue"
          end
          resource :entry_requirements, on: :member, only: %i[new], controller: "courses/entry_requirements", path: "entry-requirements" do
            get "continue"
          end
          resource :study_mode, on: :member, only: %i[new], controller: "courses/study_mode", path: "full-part-time" do
            get "continue"
          end
          resource :level, on: :member, only: %i[new], controller: "courses/level" do
            get "continue"
          end
          resource :locations, on: :member, only: %i[new], controller: "courses/sites" do
            get "back"
            get "continue"
          end
          resource :start_date, on: :member, only: %i[new], controller: "courses/start_date", path: "start-date" do
            get "continue"
          end
          resource :applications_open, on: :member, only: %i[new], controller: "courses/applications_open", path: "applications-open" do
            get "continue"
          end
          resource :age_range, on: :member, only: %i[new], controller: "courses/age_range", path: "age-range" do
            get "continue"
          end
          resource :subjects, on: :member, only: %i[new], controller: "courses/subjects", path: "subjects" do
            get "continue"
          end
          resource :modern_languages, on: :member, only: %i[new], controller: "courses/modern_languages", path: "modern-languages" do
            get "back"
            get "continue"
          end
          resource :apprenticeship, on: :member, only: %i[new], controller: "courses/apprenticeship" do
            get "continue"
          end
          resource :accredited_body, on: :member, only: %i[new], controller: "courses/accredited_body", path: "accredited-body" do
            get "continue"
            get "search_new"
          end
          resource :fee_or_salary, on: :member, only: %i[new], controller: "courses/fee_or_salary", path: "fee-or-salary" do
            get "continue"
          end

          get "confirmation"
        end

        resources :courses, param: :code, only: %i[index new create show] do
          get "/details", on: :member, to: "courses#details"

          get "/vacancies", on: :member, to: "courses/vacancies#edit"
          put "/vacancies", on: :member, to: "courses/vacancies#update"

          get "/about", on: :member, to: "courses/course_information#edit"
          patch "/about", on: :member, to: "courses/course_information#update"
        end

        scope module: :providers do
          resources :locations, except: %i[destroy show]

          get "/contact", on: :member, to: "contacts#edit"
          put "/contact", on: :member, to: "contacts#update"
          get "/visas", on: :member, to: "visas#edit"
          put "/visas", on: :member, to: "visas#update"
        end
      end
    end
  end

  namespace :support do
    get "/" => redirect("/support/providers")

    resources :providers, except: %i[destroy] do
      get :users, on: :member
      resources :courses, only: %i[index edit update]
      resources :locations
    end

    resources :users do
      scope module: :users do
        resource :providers, on: :member, only: %i[show]
      end
    end

    resources :user_permissions, only: %i[destroy]

    resources :allocations, only: %i[index show] do
      resources :uplifts, only: %i[edit update create new], controller: :allocation_uplifts
    end

    resources :data_exports, path: "data-exports", only: [:index] do
      member do
        post :download
      end
    end
  end

  namespace :api do
    namespace :v2 do
      resources :user_notification_preferences, only: %i[show update]

      resources :users, only: %i[update show] do
        resources :providers
        patch :accept_terms, on: :member
        patch :generate_and_send_magic_link, on: :collection
        scope "/recruitment_cycles/:recruitment_cycle_year" do
          resources :interrupt_page_acknowledgements, only: %i[index create]
        end
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
          post :send_vacancies_updated_notification, on: :member
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

      resources :contacts, only: %i[show update]
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
end
