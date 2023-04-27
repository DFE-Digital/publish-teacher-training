# frozen_string_literal: true

namespace :support do
  get '/', to: 'recruitment_cycle#index'

  resources :recruitment_cycles, param: :year, constraints: { year: /#{Settings.current_recruitment_cycle_year}|#{Settings.current_recruitment_cycle_year + 1}/ }, path: '' do
    namespace :providers do
      namespace :onboarding do
        resource :contacts, only: %i[new create]
        resource :check, only: %i[show update]
      end
      resource :onboarding, only: %i[new create]
    end
    resources :providers, except: %i[destroy] do
      resource :check_user, only: %i[show update], controller: 'providers/users_check', path: 'users/check'
      resources :users, controller: 'providers/users' do
        member do
          get :delete
          delete :delete, to: 'providers/users#destroy'
        end
      end
      resources :courses, only: %i[index edit update]
      resource :check_school, only: %i[show update], controller: 'providers/schools_check', path: 'schools/check'
      resources :schools do
        member do
          get :delete
          delete :delete, to: 'schools#destroy'
        end
      end
      resource :schools do
        scope module: :providers do
          scope module: :schools do
            resource :multiple, only: %i[new create], on: :member, controller: 'multiple' do
              resources :new, param: :position, only: %i[show update], controller: 'new_multiple'
              resource :check, only: %i[show update], controller: 'check_multiple'
            end
          end
        end
      end

      scope module: :providers do
        resources :accredited_providers, path: 'accredited-providers' do
          get '/search', on: :collection, to: 'accredited_provider_search#new'
          post '/search', on: :collection, to: 'accredited_provider_search#create'
          put '/search', on: :collection, to: 'accredited_provider_search#update'
        end
      end
    end
    resources :users do
      scope module: :users do
        resource :providers, on: :member, only: %i[show]
      end
    end

    resources :data_exports, path: 'data-exports', only: [:index] do
      member do
        post :download
      end
    end
  end

  resources :user_permissions, only: %i[destroy]
end
