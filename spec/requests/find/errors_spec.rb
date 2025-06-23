# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Testing Errors render", type: :request do
  describe "GET /results.*" do
    before do
      host! URI(Settings.find_url).host
      create(:course, :secondary)
    end

    it "returns html response when json format is not found" do
      get "/results.json"

      expect(response).to have_http_status(:not_acceptable)
      expect(response.body).to include("The format requested is not available")
    end
  end
end
