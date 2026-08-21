# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Find results authentication", service: :find, travel: mid_cycle do
  before do
    FeatureFlag.activate(:require_authentication_for_find_results)
    CandidateAuthHelper.mock_auth
    create(:find_developer_candidate)
  end

  it "returns a candidate to the exact search after signing in" do
    results_path = find_results_path(
      location: "Manchester",
      subjects: %w[F3],
      order: "distance",
      page: 2,
    )

    get results_path

    expect(response).to redirect_to(find_root_path)

    follow_redirect!
    expect(response.body).to include("After signing in, you’ll return to your search.")

    post "/auth/find-developer", headers: { "HTTP_REFERER" => find_root_url }
    follow_redirect!

    expect(response).to redirect_to(results_path)
    expect(request.session[Find::Authentication::RETURN_TO_AFTER_AUTHENTICATING_SESSION_KEY]).to be_nil
  end

  it "does not enable other candidate account pages" do
    get "/candidate/saved-courses"

    expect(response).to have_http_status(:not_found)
  end
end
