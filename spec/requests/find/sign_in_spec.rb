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
end
