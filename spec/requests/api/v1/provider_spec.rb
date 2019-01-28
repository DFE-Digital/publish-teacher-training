require 'rails_helper'

describe 'Providers API', type: :request do
  describe 'GET index' do
    let(:credentials) do
      ActionController::HttpAuthentication::Token
        .encode_credentials('bats')
    end
    let(:unauthorized_credentials) do
      ActionController::HttpAuthentication::Token
        .encode_credentials('foo')
    end

    describe "without changed_since parameter" do
      let!(:provider) do
        create(:provider,
              provider_name: 'ACME SCITT',
              provider_code: 'A123',
              provider_type: 'SCITT',
              site_count: 0,
              address1: 'Shoreditch Park Primary School',
              address2: '313 Bridport Pl',
              address3: nil,
              address4: 'London',
              postcode: 'N1 5JN',
              region_code: 'London',
              accrediting_provider: 'Y',
              scheme_member: 'Y',
              enrichments: [enrichment])
      end
      let!(:site) do
        create(:site,
              location_name: 'Main site',
              code: '-',
              region_code: 'London',
              provider: provider)
      end
      let(:enrichment) do
        build(:provider_enrichment,
              address1: 'Sydney Russell School',
              address2: '',
              address3: 'Dagenham',
              address4: 'Essex',
              postcode: 'RM9 5QT',
              region_code: "Scotland")
      end
      let(:provider2) do
        create(:provider,
              provider_name: 'ACME University',
              provider_code: 'B123',
              provider_type: 'University',
              address1: 'Bee School',
              address2: 'Bee Avenue',
              address3: 'Bee City',
              address4: 'Bee Hive',
              postcode: 'B3 3BB',
              region_code: 'South West',
              accrediting_provider: 'N',
              scheme_member: 'N',
              enrichments: [],
              site_count: 0)
      end
      let!(:site2) do
        create(:site,
              location_name: 'Main site',
              code: '-',
              region_code: 'Scotland',
              provider: provider2)
      end
      it 'returns http success' do
        get '/api/v1/providers', headers: { 'HTTP_AUTHORIZATION' => credentials }
        expect(response).to have_http_status(:success)
      end

      it 'returns http unauthorised' do
        get '/api/v1/providers',
            headers: { 'HTTP_AUTHORIZATION' => unauthorized_credentials }
        expect(response).to have_http_status(:unauthorized)
      end

      context 'with enrichment address data' do
        it 'JSON body response contains expected provider attributes' do
          get '/api/v1/providers',
              headers: { 'HTTP_AUTHORIZATION' => credentials }

          json = JSON.parse(response.body)
          expect(json). to eq(
            [
              {
                'accrediting_provider' => 'Y',
                'campuses' => [
                  {
                    'campus_code' => '-',
                    'name' => 'Main site',
                    'region_code' => '01',
                    'recruitment_cycle' => '2019'
                  }
                ],
                'institution_code' => 'A123',
                'institution_name' => 'ACME SCITT',
                'institution_type' => 'B',
                'address1' => 'Sydney Russell School',
                'address2' => '',
                'address3' => 'Dagenham',
                'address4' => 'Essex',
                'postcode' => 'RM9 5QT',
                'region_code' => '11',
                'scheme_member' => 'Y'
              },
              {
                'accrediting_provider' => 'N',
                'campuses' => [
                  {
                    'campus_code' => '-',
                    'name' => 'Main site',
                    'region_code' => '11',
                    'recruitment_cycle' => '2019'
                  }
                ],
                'institution_code' => 'B123',
                'institution_name' => 'ACME University',
                'institution_type' => 'O',
                'address1' => 'Bee School',
                'address2' => 'Bee Avenue',
                'address3' => 'Bee City',
                'address4' => 'Bee Hive',
                'postcode' => 'B3 3BB',
                'region_code' => '03',
                'scheme_member' => 'N'
              }
            ]
          )
        end
      end

      context 'without enrichment address data' do
        it 'JSON body response contains expected provider attributes' do
          # Simulate a provider enrichment that has no address data. It's not just
          # a matter of the attributes being nil, the data is actually missing
          # from json_data
          ProviderEnrichment.connection.update(<<~EOSQL)
            UPDATE provider_enrichment
                  SET json_data=json_data-'Address1'-'Address2'-'Address3'-'Address4'-'Postcode'-'RegionCode'
                  WHERE provider_code='#{enrichment.id}'
          EOSQL

          get '/api/v1/providers',
              headers: { 'HTTP_AUTHORIZATION' => credentials }

          json = JSON.parse(response.body)
          expect(json). to eq([
                                {
                                  'accrediting_provider' => 'Y',
                                  'campuses' => [
                                    {
                                      'campus_code' => '-',
                                      'name' => 'Main site',
                                      'region_code' => '01',
                                      'recruitment_cycle' => '2019'
                                    }
                                  ],
                                  'institution_code' => 'A123',
                                  'institution_name' => 'ACME SCITT',
                                  'institution_type' => 'B',
                                  'address1' => 'Shoreditch Park Primary School',
                                  'address2' => '313 Bridport Pl',
                                  'address3' => nil,
                                  'address4' => 'London',
                                  'postcode' => 'N1 5JN',
                                  'region_code' => '01',
                                  'scheme_member' => 'Y'
                                },
                                {
                                  'accrediting_provider' => 'N',
                                  'campuses' => [
                                    {
                                      'campus_code' => '-',
                                      'name' => 'Main site',
                                      'region_code' => '11',
                                      'recruitment_cycle' => '2019'
                                    }
                                  ],
                                  'institution_code' => 'B123',
                                  'institution_name' => 'ACME University',
                                  'institution_type' => 'O',
                                  'address1' => 'Bee School',
                                  'address2' => 'Bee Avenue',
                                  'address3' => 'Bee City',
                                  'address4' => 'Bee Hive',
                                  'postcode' => 'B3 3BB',
                                  'region_code' => '03',
                                  'scheme_member' => 'N'
                                }
                              ])
        end
      end
    end

    describe "with changed_since parameter" do
      it 'JSON body response contains expected providers' do
        old_provider = create(:provider, provider_code: "SINCE1", age: 1.hour.ago)

        updated_provider = create(:provider, provider_code: "SINCE2", age: 5.minutes.ago)

        provider_with_updated_enrichment = create(:provider, provider_code: "SINCE3", age: 1.hour.ago)
        provider_with_updated_enrichment.enrichments.first.published!

        provider_with_updated_site = create(:provider, provider_code: "SINCE4", age: 1.hour.ago)
        provider_with_updated_site.sites.first.touch

        get '/api/v1/providers',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: 10.minutes.ago.utc.iso8601 }

        json = JSON.parse(response.body)
        returned_provider_codes = json.map { |provider| provider["institution_code"] }

        expect(returned_provider_codes).not_to include old_provider.provider_code
        expect(returned_provider_codes).to include updated_provider.provider_code
        expect(returned_provider_codes).to include provider_with_updated_enrichment.provider_code
        expect(returned_provider_codes).to include provider_with_updated_site.provider_code
      end
    end
  end
end
