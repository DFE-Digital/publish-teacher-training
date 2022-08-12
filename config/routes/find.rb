namespace :find, path: "/find" do
  get "/", to: "application#index"
  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/terms-conditions", to: "pages#terms", as: :terms
  resource :cookie_preferences, only: %i[show update], path: "/cookies", as: :cookies
end
