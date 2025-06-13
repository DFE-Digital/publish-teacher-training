# frozen_string_literal: true

namespace :api do
  get "/radius_quick_link_suggestions", to: "radius_quick_link_suggestions#index"
  get "/school_suggestions", to: "school_suggestions#index"
  get "/:recruitment_cycle_year/accredited_provider_suggestions", to: "accredited_provider_suggestions#index"

  get "/saved_courses", to: "saved_courses#show"
  post "/saved_courses", to: "saved_courses#create"
  delete "/saved_courses", to: "saved_courses#destroy"
end
