constraints(FindConstraint.new) do
  get "/", to: "find/search/locations#index", as: :find
end

namespace :find, path: "/find" do
  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/terms-conditions", to: "pages#terms", as: :terms
  resource :cookie_preferences, only: %i[show update], path: "/cookies", as: :cookies

  scope module: :search do
    resources :age_groups, path: "/age-groups"
    resources :subjects
    resources :locations, path: "/"
  end
end
