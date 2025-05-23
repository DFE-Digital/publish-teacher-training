# frozen_string_literal: true

namespace :support, constraints: { host: Settings.publish_hosts }, defaults: { host: URI.parse(Settings.publish_url).host } do
  root to: "recruitment_cycle#index"

  resources :recruitment_cycle, only: %i[index], param: :year, constraints: { year: /#{Settings.current_recruitment_cycle_year}|#{Settings.current_recruitment_cycle_year + 1}/ }, path: "" do
    namespace :providers do
      namespace :onboarding do
        resource :contacts, only: %i[new create]
        resource :check, only: %i[show update]
      end
      resource :onboarding, only: %i[new create]
    end
    resources :providers, except: %i[new create destroy] do
      resource :contact_details, only: %i[edit update], path: "contact-details"
      resource :check_user, only: %i[show update], controller: "providers/users_check", path: "users/check"
      resources :users, controller: "providers/users" do
        member do
          get :delete
          delete :delete, to: "providers/users#destroy"
        end
      end

      resources :courses do
        resource :revert_withdrawal, only: %i[edit update], path: "revert-withdrawal", controller: "revert_withdrawal"
      end

      namespace :schools, module: "providers/schools" do
        resource :check, only: %i[show update]
      end
      resources :schools, except: %i[new edit update], module: "providers" do
        member do
          get :delete
          delete :delete, to: "schools#destroy"
        end

        collection do
          get "/search", to: "schools/search#new"
          post "/search", to: "schools/search#create"
          put "/search", to: "schools/search#update"
        end
      end

      namespace :schools, module: "providers/schools" do
        resource :multiple, only: %i[new create], on: :member, controller: "multiple" do
          resource :check, only: %i[show update], controller: "check_multiple" do
            get "remove_school/:urn", action: "remove_school", as: :remove_school
          end
        end
      end

      scope module: :providers do
        resources :accredited_partnerships, param: :accredited_provider_code, only: %i[index destroy], path: "accredited-partnerships" do
          member do
            get :delete
            delete :delete, to: "accredited_partnerships#destroy"
          end
          get "/check", on: :collection, to: "accredited_partnerships/checks#show"
          put "/check", on: :collection, to: "accredited_partnerships/checks#update"
        end

        resources :accredited_providers, param: :accredited_provider_code, only: %i[], path: "accredited-providers" do
          get "/search", on: :collection, to: "accredited_provider_search#new"
          post "/search", on: :collection, to: "accredited_provider_search#create"
          put "/search", on: :collection, to: "accredited_provider_search#update"
        end

        resources :copy_courses, only: %i[new create]
      end
    end
    resources :users do
      scope module: :users do
        resource :providers, on: :member, only: %i[show]
      end
    end

    resources :data_exports, path: "data-exports", only: [:index] do
      member do
        post :download
      end
    end
  end

  resources :user_permissions, only: %i[destroy]

  resources :settings, only: %i[index]
  resources :feature_flags, path: "feature-flags", only: %i[index], param: :feature_name do
    member do
      put :activate
      put :deactivate
    end
  end
  resource :environment_confirmations, path: "confirm-environment", only: %i[new create]
  resources :view_components, only: %i[index]
  resources :recruitment_cycles

  get :input_preview, controller: :pages
end
