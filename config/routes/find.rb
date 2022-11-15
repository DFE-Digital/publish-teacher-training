constraints(FindConstraint.new) do
  get "/", to: "find/search/locations#start", as: :find
end

namespace :find, path: "/find" do
  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/course/:provider_code/:course_code", to: "courses#show", as: "course"
  get "/course/:provider_code/:course_code/apply", to: "courses#apply", as: :apply
  get "/results", to: "results#index", as: "results"
  get "/location-suggestions", to: "location_suggestions#index"

  get "/feature-flags", to: "feature_flags#index"
  post "/feature-flags" => "feature_flags#update"
  get "/confirm-environment" => "confirm_environment#new"
  post "/confirm-environment" => "confirm_environment#create"
  get "/maintenance", to: "pages#maintenance", as: "maintenance"

  resource :cookie_preferences, only: %i[show update], path: "/cookies", as: :cookies
  resource :sitemap, only: :show

  scope module: :search do
    root to: "locations#start"
    get "/age-groups" => "age_groups#new"
    get "/age-groups-submit" => "age_groups#create", as: :age_groups_create
    get "/subjects" => "subjects#new"
    get "/subjects-submit" => "subjects#create", as: :subjects_create
    resources :locations, path: "/"
  end

  scope module: :result_filters, path: "/results/filter" do
    get "provider", to: "provider#new"
  end
end
