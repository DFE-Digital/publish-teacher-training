# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API gateway authentication", service: :api do
  before do
    allow(Settings.api_gateway).to receive(:secret).and_return("gateway-secret")
  end

  context "when gateway authentication is on" do
    before do
      allow(Settings.features).to receive(:api_gateway_authentication).and_return(true)
    end

    it "rejects a request without the gateway secret" do
      get "/api/public/v1/subjects"

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a request with the wrong gateway secret" do
      get "/api/public/v1/subjects", headers: { "X-Gateway-Secret" => "guess" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "serves a request carrying the gateway secret" do
      get "/api/public/v1/subjects", headers: { "X-Gateway-Secret" => "gateway-secret" }

      expect(response).to have_http_status(:ok)
    end
  end

  context "when gateway authentication is off" do
    it "serves a request without the gateway secret" do
      get "/api/public/v1/subjects"

      expect(response).to have_http_status(:ok)
    end
  end
end
