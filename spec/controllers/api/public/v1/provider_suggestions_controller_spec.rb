require "rails_helper"

RSpec.describe API::Public::V1::ProviderSuggestionsController do
  describe "#index" do
    let(:published_running_site) { create(:site_status, :published, :running) }

    before do
      @provider = create(:provider, provider_code: "oxf")
      create(:course, provider: @provider, site_statuses: [published_running_site])
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
