require "rails_helper"

RSpec.describe "Providers API", type: :request do
  describe 'GET index' do
    before do
      provider = FactoryBot.create(:provider,
        provider_name: "ACME SCITT",
        provider_code: "A123",
        provider_type: 'Y',
        site_count: 0)
      FactoryBot.create(:site,
        location_name: "Main site",
        code: "-",
        provider: provider)
    end

    it "returns http success" do
      get "/api/v1/providers", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("bat", "beta") }
      expect(response).to have_http_status(:success)
    end


    it "returns http unauthorised" do
      get "/api/v1/providers", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("foo", "bar") }
      expect(response).to have_http_status(:unauthorized)
    end

    it "JSON body response contains expected provider attributes" do
      get "/api/v1/providers", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("bat", "beta") }

      json = JSON.parse(response.body)
      expect(json). to eq(
        [
          {
            "accrediting_provider" => nil,
            "campuses" => [
              {
                "campus_code" => "-",
                "name" => "Main site",
                "recruitment_cycle" => "2019"
              }
            ],
            "institution_code" => "A123",
            "institution_name" => "ACME SCITT",
            "institution_type" => "Y",
          },
        ]
      )
    end
  end
end
