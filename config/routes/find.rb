constraints(FindConstraint.new) do
  get "/", to: "find/search/locations#index", as: :find
end

namespace :find, path: "/find" do
  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/course/:provider_code/:course_code", to: "courses#show", as: "course"
  get "/course/:provider_code/:course_code/apply", to: "courses#apply", as: :apply
  resource :cookie_preferences, only: %i[show update], path: "/cookies", as: :cookies

  scope module: :search do
    resources :age_groups, path: "/age-groups"
    resources :subjects
    resources :locations, path: "/"
  end
end
