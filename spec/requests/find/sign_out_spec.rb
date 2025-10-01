# frozen_string_literal: true

require "rails_helper"

describe "DELETE /sign-out for OneLogin Strategy", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    allow(Settings.one_login).to receive(:enabled).and_return(true)
  end

  context "when user has a session" do
    before { allow(Current).to receive(:session).and_return(build(:session)) }

    it "redirects to one-login signout endpoint" do
      delete "/sign-out"
      expect(response).to have_http_status(:redirect)
      expect(response.location).to match("#{Settings.one_login.idp_base_url}logout")
    end
  end

  context "when user doesn't have a session" do
    it "redirects to the find root url" do
      delete "/sign-out"
      expect(response).to have_http_status(:redirect)
      expect(response.location).to match(find_root_path)
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end
  end
end
