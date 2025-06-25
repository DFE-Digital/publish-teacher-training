# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication error", service: :find, type: :request do
  include OmniAuth::Test

  before do
    create(:find_developer_candidate)

    CandidateAuthHelper.mock_error_auth
  end

  describe "POST /auth/find-developer/callback" do
    it "triggers an error and renders the error page" do
      allow(Sentry).to receive(:capture_exception)
      allow(OmniAuth.config.failure_raise_out_environments).to receive(:include?).and_return(true)

      post "/auth/find-developer/callback", params: {}
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Authentication error")
      expect(Sentry).to have_received(:capture_exception)
    end
  end
end
