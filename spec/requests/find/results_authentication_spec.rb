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

    get results_path, headers: { "HTTP_REFERER" => "https://www.example.gov.uk/teacher-training" }

    expect(response).to redirect_to(find_results_sign_in_path)

    follow_redirect!
    expect(response.parsed_body.title).to eq("Sign in to view search results - Find teacher training courses - GOV.UK")
    expect(response.body).to include("You need a GOV.UK One Login to search for teacher training courses.")
    expect(response.body).to include("After signing in, you’ll return to your search.")
    sign_in_form = response.parsed_body.at_css("main form[action='/auth/find-developer']")
    expect(sign_in_form["method"]).to eq("post")
    expect(sign_in_form.at_css("button").text.strip).to eq("Sign in")

    post "/auth/find-developer", headers: { "HTTP_REFERER" => find_results_sign_in_url }
    follow_redirect!

    expect(response).to redirect_to(results_path)
    expect(request.session[Find::Authentication::RETURN_TO_AFTER_AUTHENTICATING_SESSION_KEY]).to be_nil
  end

  it "returns to the search without signing in if the flag is switched off" do
    results_path = find_results_path(location: "Manchester", subjects: %w[F3])

    get results_path
    FeatureFlag.deactivate(:require_authentication_for_find_results)
    follow_redirect!

    expect(response).to redirect_to(results_path)
  end

  it "does not enable other candidate account pages" do
    get "/candidate/saved-courses"

    expect(response).to have_http_status(:not_found)
  end
end
