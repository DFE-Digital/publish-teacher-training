# frozen_string_literal: true

require "rails_helper"

describe "/auth/find-developer", service: :find do
  context "when page parameter is invalid" do
    before do
      FeatureFlag.activate(:candidate_accounts)
      CandidateAuthHelper.mock_auth
    end

    it "responds successfully" do
      post "/auth/find-developer"
      follow_redirect!
      expect(response).to have_http_status(:redirect)
    end

    it "redirects user to the original url accessed before signing in" do
      get "/candidate/saved-courses"
      follow_redirect! # redirect to homepage (sets the session redirect url)

      post "/auth/find-developer"
      follow_redirect! # redirect to callback url
      follow_redirect! # redirect to saved-courses url set in the session

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.title).to eq("Saved courses - Find teacher training courses - GOV.UK")
    end
  end

  describe "concurrent session handling" do
    before do
      FeatureFlag.activate(:candidate_accounts)
      CandidateAuthHelper.mock_auth
    end

    it "destroys any existing sessions for the candidate before creating the new one" do
      candidate = create(:find_developer_candidate)
      create(:session, sessionable: candidate, session_key: "old-browser-session-key")
      create(:session, sessionable: candidate, session_key: "another-device-session-key")

      expect {
        post "/auth/find-developer"
        follow_redirect!
      }.to change { candidate.sessions.reload.count }.from(2).to(1)

      expect(candidate.sessions.pluck(:session_key)).not_to include(
        "old-browser-session-key",
        "another-device-session-key",
      )
    end
  end
end
