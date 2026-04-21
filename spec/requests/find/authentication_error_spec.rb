# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication error", service: :find, type: :request do
  before do
    create(:find_developer_candidate)
    FeatureFlag.activate(:candidate_accounts)

    CandidateAuthHelper.mock_error_auth
  end

  describe "POST /auth/find-developer/callback" do
    it "triggers an error and renders the error page" do
      allow(Sentry).to receive(:capture_message)
      allow(ErrorReporting::RateLimiter).to receive(:report?).and_return(true)

      post "/auth/find-developer/callback"
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Authentication error")
      expect(Sentry).to have_received(:capture_message)
    end
  end

  describe "GET /auth/failure" do
    before { allow(Sentry).to receive(:capture_message) }

    it "always reports known gem error types without checking the threshold" do
      expect(ErrorReporting::RateLimiter).not_to receive(:report?)

      get "/auth/failure", params: { message: "callback_state_mismatch" }

      expect(Sentry).to have_received(:capture_message).with(
        "One Login failure",
        hash_including(tags: hash_including(error_type: "callback_state_mismatch", sample_rate: 1)),
      )
    end

    it "reports invalid_authenticity_token once the threshold is reached" do
      allow(ErrorReporting::RateLimiter).to receive(:report?)
        .with(key: "one_login:invalid_authenticity_token", threshold: 10)
        .and_return(true)

      get "/auth/failure", params: { message: "ActionController::InvalidAuthenticityToken" }

      expect(Sentry).to have_received(:capture_message).with(
        "One Login failure",
        hash_including(tags: hash_including(error_type: "invalid_authenticity_token", sample_rate: 10)),
      )
    end

    it "stays silent for invalid_authenticity_token below the threshold" do
      allow(ErrorReporting::RateLimiter).to receive(:report?).and_return(false)

      get "/auth/failure", params: { message: "ActionController::InvalidAuthenticityToken" }

      expect(Sentry).not_to have_received(:capture_message)
    end

    it "buckets unknown error types as 'other' to bound cardinality, and applies the threshold" do
      allow(ErrorReporting::RateLimiter).to receive(:report?)
        .with(key: "one_login:other", threshold: 10)
        .and_return(true)

      get "/auth/failure", params: { message: "<attacker-controlled>" }

      expect(Sentry).to have_received(:capture_message).with(
        "One Login failure",
        hash_including(tags: hash_including(error_type: "other", sample_rate: 10)),
      )
    end

    it "treats a blank message as 'other'" do
      allow(ErrorReporting::RateLimiter).to receive(:report?)
        .with(key: "one_login:other", threshold: 10)
        .and_return(true)

      get "/auth/failure"

      expect(Sentry).to have_received(:capture_message).with(
        "One Login failure",
        hash_including(tags: hash_including(error_type: "other")),
      )
    end
  end
end
