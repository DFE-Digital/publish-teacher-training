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
              provider_type: :scitt,
              site_count: 0,
              address1: 'Shoreditch Park Primary School',
              address2: '313 Bridport Pl',
              address3: nil,
              address4: 'London',
              postcode: 'N1 5JN',
              telephone: '020 812 345 678',
              email: 'info@acmescitt.education.uk',
              contact_name: 'Amy Smith',
              region_code: :london,
              accrediting_provider: 'Y',
              scheme_member: 'Y',
              last_published_at: DateTime.now.utc,
              enrichments: [enrichment])
      end
      let!(:site) do
        create(:site,
              location_name: 'Main site',
              code: '-',
              region_code: :london,
              provider: provider)
      end
      let(:enrichment) do
        build(:provider_enrichment,
              address1: 'Sydney Russell School',
              address2: '',
              address3: 'Dagenham',
              address4: 'Essex',
              postcode: 'RM9 5QT',
              region_code: :scotland)
      end
      let(:provider2) do
        create(:provider,
              provider_name: 'ACME University',
              provider_code: 'B123',
              provider_type: :university,
              address1: 'Bee School',
              address2: 'Bee Avenue',
              address3: 'Bee City',
              address4: 'Bee Hive',
              postcode: 'B3 3BB',
              telephone: '01273 345 678',
              email: 'info@acmeuniversity.education.uk',
              contact_name: 'James Brown',
              region_code: :south_west,
              accrediting_provider: 'N',
              scheme_member: 'N',
              last_published_at: DateTime.now.utc,
              enrichments: [],
              site_count: 0)
      end
      let!(:site2) do
        create(:site,
              location_name: 'Main site',
              code: '-',
              region_code: :scotland,
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
                'scheme_member' => 'Y',
                'telephone' => '020 812 345 678',
                'email' => 'info@acmescitt.education.uk',
                'contact_name' => 'Amy Smith'
              },
              {
                'accrediting_provider' => 'N',
                'campuses' => [
                  {
                    'campus_code' => '-',
                    'name' => 'Main site',
                    'region_code' => '11',
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
                'scheme_member' => 'N',
                'telephone' => '01273 345 678',
                'email' => 'info@acmeuniversity.education.uk',
                'contact_name' => 'James Brown'
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
                                  'scheme_member' => 'Y',
                                  'telephone' => '020 812 345 678',
                                  'email' => 'info@acmescitt.education.uk',
                                  'contact_name' => 'Amy Smith'
                                },
                                {
                                  'accrediting_provider' => 'N',
                                  'campuses' => [
                                    {
                                      'campus_code' => '-',
                                      'name' => 'Main site',
                                      'region_code' => '11',
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
                                  'scheme_member' => 'N',
                                  'telephone' => '01273 345 678',
                                  'email' => 'info@acmeuniversity.education.uk',
                                  'contact_name' => 'James Brown'
                                }
                              ])
        end
      end
    end

    context "with changed_since parameter" do
      describe "JSON body response" do
        it 'contains expected providers' do
          old_provider = create(:provider,
                                provider_code: "SINCE1",
                                last_published_at: 1.hour.ago)

          updated_provider = create(:provider,
                                    provider_code: "SINCE2",
                                    last_published_at: 5.minutes.ago)

          get '/api/v1/providers',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: { changed_since: 10.minutes.ago.utc.iso8601 }

          returned_provider_codes = get_provider_codes_from_body(response.body)

          expect(returned_provider_codes).not_to include old_provider.provider_code
          expect(returned_provider_codes).to include updated_provider.provider_code
        end
      end

      it 'includes correct next link in response headers' do
        create(:provider, provider_code: "LAST1", last_published_at: 10.minutes.ago)

        timestamp_of_last_provider = 2.minutes.ago
        last_provider_in_results = create(:provider,
                                          provider_code: "LAST2",
                                          last_published_at: timestamp_of_last_provider)

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
            create(:provider, provider_code: "PROV#{i + 1}",
                   last_published_at: (20 - i).minutes.ago,
                   sites: [],
                   enrichments: [])
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
    end
  end
end
