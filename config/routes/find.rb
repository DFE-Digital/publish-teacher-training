# frozen_string_literal: true

namespace :find, path: "/", defaults: { host: URI.parse(Settings.find_url).host } do
  root to: "homepage#index"

  get "track_click", to: "track#track_click"

  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/privacy", to: "pages#privacy", as: :privacy
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/course/:provider_code/:course_code", to: "courses#show", as: "course"
  get "/course/:provider_code/:course_code/placements", to: "placements#index", as: :placements
  get "/course/:provider_code/:course_code/apply", to: "courses#apply", as: :apply
  get "/course/:provider_code/:course_code/git/:git_path", to: "courses#git_redirect", as: :get_into_teaching_redirect
  get "/course/:provider_code/:course_code/provider/website", to: "courses#provider_website", as: :provider_website
  get "/course/:provider_code/:course_code/confirm-apply", to: "courses#confirm_apply", as: :confirm_apply

  get "/geolocation-suggestions", to: "geolocation_suggestions#index"

  get "/results", to: "results#index", as: "results"
  get "/primary", to: "primary_subjects#index"
  post "/primary", to: "primary_subjects#submit"
  get "/secondary", to: "secondary_subjects#index"
  post "/secondary", to: "secondary_subjects#submit"

  get "/cycle-has-ended", to: "pages#cycle_has_ended", as: "cycle_has_ended"

  scope module: :courses, path: "/courses" do
    get "/:provider_code/:course_code/provider", to: "providers#show", as: :provider
    get "/:provider_code/:course_code/accredited-by", to: "accrediting_providers#show", as: :accrediting_provider
    get "/:provider_code/:course_code/training-with-disabilities", to: "training_with_disabilities#show", as: :training_with_disabilities
  end

  constraints ->(_req) { FeatureFlag.active?(:candidate_accounts) } do
    scope module: "authentication" do
      resource :sessions, path: "auth", only: %i[] do
        get ":provider/callback", action: :callback

        get "/failure", to: "sessions#failure"
      end
      delete "/sign-out", to: "sessions#destroy"
    end

    scope path: "candidate", module: "candidates", as: "candidate" do
      resources :saved_courses, only: %i[index create destroy], path: "saved-courses" do
        post :undo, on: :collection
      end
    end
  end

  get "/maintenance", to: "pages#maintenance", as: "maintenance"
  get "/cycles", to: "switcher#cycles", as: :cycles
  post "/cycles", to: "switcher#update", as: :switch_cycle_schedule

  resource :cookie_preferences, only: %i[show update], path: "/cookies", as: :cookies
  resource :sitemap, only: :show
  resource :feedbacks, only: %i[new create], path: "/feedback", as: :feedback

  scope via: :all do
    match "/404", to: "errors#not_found"
    match "/500", to: "errors#internal_server_error"
    match "/403", to: "errors#forbidden"
  end
end
