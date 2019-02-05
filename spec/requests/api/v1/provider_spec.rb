require 'rails_helper'

def get_provider_codes_from_body(body)
  json = JSON.parse(body)
  json.map { |provider| provider["institution_code"] }
end

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

    context "without changed_since parameter" do
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
        get '/api/v1/2019/providers', headers: { 'HTTP_AUTHORIZATION' => credentials }
        expect(response).to have_http_status(:success)
      end

      it 'returns http unauthorised' do
        get '/api/v1/2019/providers',
            headers: { 'HTTP_AUTHORIZATION' => unauthorized_credentials }
        expect(response).to have_http_status(:unauthorized)
      end

      context 'with enrichment address data' do
        it 'JSON body response contains expected provider attributes' do
          get '/api/v1/2019/providers',
              headers: { 'HTTP_AUTHORIZATION' => credentials }

          json = JSON.parse(response.body)
          expect(json). to match_array(
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
                  WHERE provider_code='#{enrichment.provider_code}'
          EOSQL

          get '/api/v1/providers',
              headers: { 'HTTP_AUTHORIZATION' => credentials }

          json = JSON.parse(response.body)
          expect(json). to match_array([
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

    context "with changed_since parameter" do
      describe "JSON body response" do
        it 'contains expected providers' do
          old_provider = create(:provider, provider_code: "SINCE1", age: 1.hour.ago)

          updated_provider = create(:provider, provider_code: "SINCE2", age: 5.minutes.ago)

          provider_with_updated_enrichment = create(:provider, provider_code: "SINCE3", age: 1.hour.ago)
          provider_with_updated_enrichment.enrichments.first.published!

          provider_with_updated_site = create(:provider, provider_code: "SINCE4", age: 1.hour.ago)
          provider_with_updated_site.sites.first.touch

          get '/api/v1/providers',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: { changed_since: 10.minutes.ago.utc.iso8601 }

          returned_provider_codes = get_provider_codes_from_body(response.body)

          expect(returned_provider_codes).not_to include old_provider.provider_code
          expect(returned_provider_codes).to include updated_provider.provider_code
          expect(returned_provider_codes).to include provider_with_updated_enrichment.provider_code
          expect(returned_provider_codes).to include provider_with_updated_site.provider_code
        end
      end

      it 'includes correct next link in response headers' do
        create(:provider, provider_code: "LAST1", age: 10.minutes.ago)

        timestamp_of_last_provider = 2.minutes.ago
        last_provider_in_results = create(:provider, provider_code: "LAST2", age: timestamp_of_last_provider)

        get '/api/v1/providers',
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: { changed_since: 30.minutes.ago.utc.iso8601 }

        expect(response.headers).to have_key "Link"
        expected = /#{request.base_url + request.path}\?changed_since=#{(timestamp_of_last_provider + 1.second).utc.iso8601}&from_provider_id=#{last_provider_in_results.id}&per_page=100; rel="next"$/
        expect(response.headers["Link"]).to match expected
      end

      it 'includes correct next link when there is an empty set' do
        provided_timestamp = 5.minutes.ago.utc.iso8601

        get '/api/v1/providers',
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: { changed_since: provided_timestamp }

        expected = /#{request.base_url + request.path}\?changed_since=#{provided_timestamp}&from_provider_id=&per_page=100; rel="next"$/
        expect(response.headers["Link"]).to match expected
      end

      context "with many providers" do
        before do
          11.times do |i|
            create(:provider, provider_code: "PROV#{i + 1}", age: (20 - i).minutes.ago, sites: [], enrichments: [])
          end
        end

        it 'pages properly' do
          get '/api/v1/providers',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: 21.minutes.ago.utc.iso8601, per_page: 10 }

          returned_provider_codes = get_provider_codes_from_body(response.body)

          expected_provider_codes = (1..10).map { |n| "PROV#{n}" }
          expect(returned_provider_codes).to match_array expected_provider_codes

          next_url = response.headers["Link"]

          get next_url,
            headers: { 'HTTP_AUTHORIZATION' => credentials }

          returned_provider_codes = get_provider_codes_from_body(response.body)

          expect(returned_provider_codes.size).to eq 1
          expect(returned_provider_codes).to include "PROV11"

          next_url = response.headers["Link"]

          get next_url,
            headers: { 'HTTP_AUTHORIZATION' => credentials }

          returned_provider_codes = get_provider_codes_from_body(response.body)

          expect(returned_provider_codes.size).to eq 0
        end
      end

      context 'a single provider with multiple published enrichments' do
        let!(:provider) do
          create(:provider,
                site_count: 0,
                updated_at: 5.days.ago,
                enrichments: [new_published_enrichment, old_published_enrichment])
        end
        let!(:site1) do
          create(:site,
                updated_at: 4.days.ago,
                provider: provider)
        end
        let!(:site2) do
          create(:site,
                updated_at: 3.days.ago,
                provider: provider)
        end
        let(:new_published_enrichment) do
          build(:provider_enrichment,
                address1: 'enrichment1 address1',
                address2: 'enrichment1 address2',
                address3: 'enrichment1 address3',
                address4: 'enrichment1 address4',
                postcode: 'enrichment1 postcode',
                updated_at: 1.days.ago,
                status: 1)
        end
        let(:old_published_enrichment) do
          build(:provider_enrichment,
                updated_at: 6.days.ago,
                status: 1)
        end
        it 'there is no dupes' do
          get '/api/v1/2019/providers',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: { changed_since: 2.days.ago }
          json = JSON.parse(response.body)

          expect(json.count). to eql(1)
          expect(json.first['address1']). to eql('enrichment1 address1')
          expect(json.first['address2']). to eql('enrichment1 address2')
          expect(json.first['address3']). to eql('enrichment1 address3')
          expect(json.first['address4']). to eql('enrichment1 address4')
          expect(json.first['postcode']). to eql('enrichment1 postcode')
          expect(json.first['campuses'].count). to eql(2)
        end
      end
    end
  end
end
