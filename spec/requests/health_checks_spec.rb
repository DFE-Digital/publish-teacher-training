require "rails_helper"

describe "health check requests" do
  describe "GET /ping" do
    it "returns PONG" do
      get "/ping"

      expect(response.body).to eq "PONG"
    end
  end
end
