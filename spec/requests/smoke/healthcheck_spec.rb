# frozen_string_literal: true

require "rails_helper"

describe "V1 Public API healthcheck smoke test", :smoke do
  let(:base_url) { Settings.publish_url.sub("www", "api") }

  describe "GET /healthcheck" do
    before do
      get "#{base_url}/healthcheck"
    end

    it "returns HTTP success" do
      expect(response.status).to eq(200)
    end

    it "returns JSON" do
      expect(response.media_type).to eq("application/json")
    end

    it "returns the expected response report" do
      expect(response.body).to eq(
        {
          checks: {
            database: true,
            redis: true,
            sidekiq_processes: true,
          },
        }.to_json,
      )
    end
  end
end
