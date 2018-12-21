Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :providers
      resources :subjects
    end
  end
end
