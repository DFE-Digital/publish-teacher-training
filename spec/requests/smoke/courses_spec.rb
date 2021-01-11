# frozen_string_literal: true

require "rails_helper"

describe "V1 Public API courses smoke test", :smoke do
  let(:base_url) { Settings.publish_url.sub("www", "api") }

  describe "GET /api/public/v1/courses" do
    before do
      get "#{base_url}/api/public/v1/courses"
    end

    it "returns HTTP success" do
      expect(response.status).to eq(200)
    end
  end
end
