Rails.application.routes.draw do
  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat
  get :reporting, controller: :reporting

  constraints(APIConstraint.new) do
    get "/", to: redirect("/docs/")
  end

  constraints(host: /www2\./) do
    match "/(*path)" => redirect { |_, req| "#{Settings.base_url}#{req.fullpath}" }, via: %i[get post put]
  end

  root to: "publish/providers#index"

  mount OpenApi::Rswag::Ui::Engine => "/api-docs"
  mount OpenApi::Rswag::Api::Engine => "/api-docs"

  get "/sign-in", to: "sign_in#index"
  get "/user-not-found", to: "sign_in#new"
  get "/sign-out", to: "sessions#sign_out"

  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/guidance", to: "pages#guidance", as: :guidance
  get "/performance-dashboard", to: "pages#performance_dashboard", as: :performance_dashboard
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/how-to-use-this-service", to: "pages#how_to_use_this_service"
  get "/how-to-use-this-service/course-summary-examples", to: "pages#course_summary_examples", as: :course_summary_examples
  get "/how-to-use-this-service/writing-descriptions-for-publish-teacher-training-courses", to: "pages#writing_descriptions_for_publish_teacher_training_courses", as: :writing_descriptions_for_publish_teacher_training_courses

  if FeatureService.enabled?(:google_analytics)
    resource :cookie_preferences, only: %i[show update], path: "/cookies", as: :cookies
  else
    get "/cookies", to: "pages#cookies", as: :cookies
  end

  if AuthenticationService.magic_link?
    get "/sign-in/magic-link", to: "magic_links#new", as: :magic_links
    post "/magic-link", to: "magic_links#create"
    get "/magic-link-sent", to: "magic_links#magic_link_sent"
    get "/signin_with_magic_link", to: "magic_link_sessions#create", as: "signin_with_magic_link"
    get "/auth/dfe/signout", to: "sessions#destroy"
  elsif AuthenticationService.persona?
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
    get "/providers/search", to: "providers#search"
    get "/providers/suggest", to: "providers#suggest"
    get "/rollover-recruitment", to: "rollover_recruitment#new", as: :rollover_recruitment
    post "/rollover-recruitment", to: "rollover_recruitment#create"

    get "/accept-terms", to: "terms#edit", as: :accept_terms
    patch "/accept-terms", to: "terms#update"

    resources :notifications, path: "/notifications", controller: "notifications", only: %i[index update]

    resources :access_requests, path: "/access-requests", controller: "access_requests", only: %i[new index create] do
      member do
        post :approve
        delete :destroy
        get :confirm
        get "/inform-publisher", to: "access_requests#inform_publisher"
      end
    end

    resources :providers, path: "organisations", param: :code, only: [:show] do
      get "/users", on: :member, to: "users#index"
      get "/request-access", on: :member, to: "providers/access_requests#new"
      post "/request-access", on: :member, to: "providers/access_requests#create"
      get "locations"

      resources :recruitment_cycles, param: :year, constraints: { year: /#{Settings.current_recruitment_cycle_year}|#{Settings.current_recruitment_cycle_year + 1}/ }, path: "", only: [:show] do
        get "/about", on: :member, to: "providers#about"
        put "/about", on: :member, to: "providers#update"
        get "/details", on: :member, to: "providers#details"
        get "/training-providers-courses", on: :member, to: "training_providers/course_exports#index", as: "download_training_providers_courses"

        resources :training_providers, path: "/training-providers", only: [:index], param: :code do
          resources :courses, only: [:index], controller: "training_providers/courses"
        end

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

          get "/age_range", on: :member, to: "courses/age_range#edit"
          put "/age_range", on: :member, to: "courses/age_range#update"

          get "/vacancies", on: :member, to: "courses/vacancies#edit"
          put "/vacancies", on: :member, to: "courses/vacancies#update"

          get "/about", on: :member, to: "courses/course_information#edit"
          patch "/about", on: :member, to: "courses/course_information#update"
          get "/requirements", on: :member, to: "courses/requirements#edit"
          patch "/requirements", on: :member, to: "courses/requirements#update"
          get "/fees", on: :member, to: "courses/fees#edit"
          patch "/fees", on: :member, to: "courses/fees#update"
          get "/salary", on: :member, to: "courses/salary#edit"
          patch "/salary", on: :member, to: "courses/salary#update"

          get "/withdraw", on: :member, to: "courses/withdrawals#edit"
          patch "/withdraw", on: :member, to: "courses/withdrawals#update"
          get "/delete", on: :member, to: "courses/deletions#edit"
          delete "/delete", on: :member, to: "courses/deletions#destroy"
          post "/publish", on: :member, to: "courses#publish"

          get "/rollover", on: :member, to: "courses/draft_rollover#edit"
          post "/rollover", on: :member, to: "courses/draft_rollover#update"

          get "/locations", on: :member, to: "courses/sites#edit"
          put "/locations", on: :member, to: "courses/sites#update"

          get "/preview", on: :member, to: "courses#preview"

          get "/outcome", on: :member, to: "courses/outcome#edit"
          put "/outcome", on: :member, to: "courses/outcome#update"

          get "/full-part-time", on: :member, to: "courses/study_mode#edit"
          put "/full-part-time", on: :member, to: "courses/study_mode#update"

          get "/degrees/start", on: :member, to: "courses/degrees/start#edit"
          put "/degrees/start", on: :member, to: "courses/degrees/start#update"

          get "/degrees/grade", on: :member, to: "courses/degrees/grade#edit"
          put "/degrees/grade", on: :member, to: "courses/degrees/grade#update"

          get "/degrees/subject-requirements", on: :member, to: "courses/degrees/subject_requirements#edit"
          put "/degrees/subject-requirements", on: :member, to: "courses/degrees/subject_requirements#update"

          get "/gcses-pending-or-equivalency-tests", on: :member, to: "courses/gcse_requirements#edit"
          put "/gcses-pending-or-equivalency-tests", on: :member, to: "courses/gcse_requirements#update"

          get "/subjects", on: :member, to: "courses/subjects#edit"
          put "/subjects", on: :member, to: "courses/subjects#update"

          get "/modern-languages", on: :member, to: "courses/modern_languages#edit"
          put "/modern-languages", on: :member, to: "courses/modern_languages#update"
        end

        scope module: :providers do
          resources :locations, except: %i[destroy show]

          get "/contact", on: :member, to: "contacts#edit"
          put "/contact", on: :member, to: "contacts#update"
          get "/visas", on: :member, to: "visas#edit"
          put "/visas", on: :member, to: "visas#update"

          resources :allocations, only: %i[index], on: :member, param: :training_provider_code do
            collection do
              get :initial_request, path: "request"
              post :initial_request, path: "request"
            end

            member do
              get :new_repeat_request, path: "new-repeat-request"
              post :create
              get :show
              get :edit, path: "edit", param: :id
              patch :update
            end
            scope :initial_requests do
              get :edit, to: "edit_initial_allocations#edit", as: "get_edit_initial_request"
              post :edit, to: "edit_initial_allocations#edit", as: "post_edit_initial_request"
              post :update, to: "edit_initial_allocations#update", as: "update_initial_request"
              get :delete, to: "edit_initial_allocations#delete", as: "delete_initial_request"
              get :confirm_deletion, to: "edit_initial_allocations#confirm_deletion"
            end
          end
        end
      end
    end
  end

  namespace :support do
    get "/" => redirect("/support/providers")

    resources :providers, except: %i[destroy] do
      resources :users, only: %i[index show], controller: "providers/users" do
        member do
          get :delete
          delete :delete, to: "providers/users#destroy"
        end
      end
      resources :courses, only: %i[index edit update]
      resources :locations
      resources :users, controller: "providers/users" do
        collection do
          get :check, path: "check"
          post :check, path: "check"
        end
      end
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
end
