namespace :support do
  get "/", to: "recruitment_cycle#index"

  resources :recruitment_cycles, param: :year, constraints: { year: /#{Settings.current_recruitment_cycle_year}|#{Settings.current_recruitment_cycle_year + 1}/ }, path: "" do
    resources :providers, except: %i[destroy] do
      resource :check_user, only: %i[show update], controller: "providers/users_check", path: "users/check"
      resources :users, controller: "providers/users" do
        member do
          get :delete
          delete :delete, to: "providers/users#destroy"
        end
      end
      resources :courses, only: %i[index edit update]
      resources :locations
    end
    resources :users do
      scope module: :users do
        resource :providers, on: :member, only: %i[show]
      end
    end

    resources :allocations, only: %i[index show] do
      resources :uplifts, only: %i[edit update create new], controller: :allocation_uplifts
    end

    resources :data_exports, path: "data-exports", only: [:index] do
      member do
        post :download
      end
    end
  end

  resources :user_permissions, only: %i[destroy]
end
