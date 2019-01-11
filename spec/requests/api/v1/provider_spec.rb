require "rails_helper"

RSpec.describe "Providers API", type: :request do
  describe 'GET index' do
    before do
      provider = FactoryBot.create(:provider,
        provider_name: "ACME SCITT",
        provider_code: "A123",
        provider_type: 'SCITT',
        site_count: 0)
      FactoryBot.create(:site,
        location_name: "Main site",
        code: "-",
        provider: provider)
      FactoryBot.create(:provider_enrichment,
                        provider_code: provider.provider_code,
                        json_data: { "Address1" => "Sydney Russell School",
                                    "Address2" => "Parsloes Avenue",
                                    "Address3" => "Dagenham",
                                    "Address4" => "Essex",
                                    "Postcode" => "RM9 5QT" })
      provider = FactoryBot.create(:provider,
        provider_name: "ACME University",
        provider_code: "B123",
        provider_type: 'University',
        site_count: 0)
      FactoryBot.create(:site,
        location_name: "Main site",
        code: "-",
        provider: provider)
      FactoryBot.create(:provider_enrichment,
                        provider_code: provider.provider_code,
                        json_data: { "Address1" => "Bee School",
                                    "Address2" => "Bee Avenue",
                                    "Address3" => "Bee City",
                                    "Address4" => "Bee Hive",
                                    "Postcode" => "B3 3BB" })
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
            "institution_type" => "B",
            "address1" => "Sydney Russell School",
            "address2" => "Parsloes Avenue",
            "address3" => "Dagenham",
            "address4" => "Essex",
            "postcode" => "RM9 5QT"
          },
          {
            "accrediting_provider" => nil,
            "campuses" => [
              {
                "campus_code" => "-",
                "name" => "Main site",
                "recruitment_cycle" => "2019"
              }
            ],
            "institution_code" => "B123",
            "institution_name" => "ACME University",
            "institution_type" => "O",
            "address1" => "Bee School",
            "address2" => "Bee Avenue",
            "address3" => "Bee City",
            "address4" => "Bee Hive",
            "postcode" => "B3 3BB"
          },
        ]
      )
    end
  end
end
