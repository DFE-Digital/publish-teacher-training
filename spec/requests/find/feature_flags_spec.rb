# frozen_string_literal: true

require "rails_helper"

describe "/feature-flags" do
  it "responds with unauthorized without basic auth" do
    get "/feature-flags"

    expect(response).to have_http_status(:unauthorized)
  end

  it "responds with 200 without basic auth" do
    get "/feature-flags", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }

    expect(response).to have_http_status(:ok)
  end

  context "when the cycle has ended" do
    before do
      allow(Find::CycleTimetable).to receive(:find_down?).and_return(true)
    end

    it "responds with 200 without basic auth" do
      get "/feature-flags", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }

      expect(response).to have_http_status(:ok)
    end
  end
end
