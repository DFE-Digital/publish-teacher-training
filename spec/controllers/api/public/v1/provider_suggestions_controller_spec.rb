# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Public::V1::ProviderSuggestionsController do
  describe "#index" do
    before do
      @provider = create(:provider, provider_code: "oxf")
      create(:course, :published, provider: @provider)
      get :index, params: {
        query: "oxf",
      }
    end

    it "responds with a ProviderSuggestionListResponse" do
      expect(json_response["data"].first["id"]).to eql(@provider.id.to_s)
      expect(json_response["data"].first["type"]).to eql("provider_suggestions")
      expect(json_response["data"].first["attributes"]["name"]).to eql(@provider.provider_name)
      expect(json_response["data"].first["attributes"]["code"]).to eql(@provider.provider_code)
    end
  end
end
