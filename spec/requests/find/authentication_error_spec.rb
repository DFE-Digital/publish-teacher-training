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

      post "/auth/find-developer/callback"
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Authentication error")
      expect(Sentry).to have_received(:capture_message)
    end
  end
end
