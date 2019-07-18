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

    let(:get_index) { get '/api/v1/2019/providers', headers: { 'HTTP_AUTHORIZATION' => credentials } }

    context "without changed_since parameter" do
      let(:ucas_preferences) do
        build(:ucas_preferences,
              type_of_gt12: :not_coming,
              send_application_alerts: :all,
              application_alert_email: 'application_alert_recipient@acmescitt.education.uk')
      end
      let(:contacts) do
        [
          build(:contact, type: 'admin',
                          name: 'Admin Contact A123',
                          email: 'admin@acmescitt.education.uk',
                          telephone: '020 812 345 678'),
          build(:contact, type: 'utt',
                          name: 'Utt Contact A123',
                          email: 'utt@acmescitt.education.uk',
                          telephone: '020 812 345 678'),
          build(:contact, type: 'web_link',
                          name: 'Web Link Contact A123',
                          email: 'web_link@acmescitt.education.uk',
                          telephone: '020 812 345 678'),
          build(:contact, type: 'fraud',
                          name: 'Fraud Contact A123',
                          email: 'fraud@acmescitt.education.uk',
                          telephone: '020 812 345 678'),
          build(:contact, type: 'finance',
                          name: 'Finance Contact A123',
                          email: 'finance@acmescitt.education.uk',
                          telephone: '020 812 345 678')
        ]
      end
      let(:provider) do
        create(:provider,
               provider_name: 'ACME SCITT',
               provider_code: 'A123',
               provider_type: :scitt,
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
               enrichments: [],
               ucas_preferences: ucas_preferences,
               contacts: contacts,
               sites: [site])
      end
      let(:site) do
        build(:site,
              location_name: 'Main site 1',
              code: '-',
              region_code: :london)
      end
      let(:ucas_preferences2) do
        build(:ucas_preferences,
              type_of_gt12: :coming_or_not,
              send_application_alerts: :none,
              application_alert_email: nil)
      end
      let(:contacts2) do
        [
          build(:contact, type: 'admin',
                          name: 'Admin Contact B123',
                          email: 'admin@acmeuniversity.education.uk',
                          telephone: '01273 345 678'),
          build(:contact, type: 'utt',
                          name: 'Utt Contact B123',
                          email: 'utt@acmeuniversity.education.uk',
                          telephone: '01273 345 678'),
          build(:contact, type: 'web_link',
                          name: 'Web Link Contact B123',
                          email: 'web_link@acmeuniversity.education.uk',
                          telephone: '01273 345 678'),
          build(:contact, type: 'fraud',
                          name: 'Fraud Contact B123',
                          email: 'fraud@acmeuniversity.education.uk',
                          telephone: '01273 345 678'),
          build(:contact, type: 'finance',
                          name: 'Finance Contact B123',
                          email: 'finance@acmeuniversity.education.uk',
                          telephone: '01273 345 678')
        ]
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
               ucas_preferences: ucas_preferences2,
               contacts: contacts2,
               sites: [site2])
      end
      let(:site2) do
        build(:site,
              location_name: 'Main site 2',
              code: '-',
              region_code: :scotland)
      end

      before do
        provider
        provider2
        get_index
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns http unauthorised' do
        get '/api/v1/2019/providers',
            headers: { 'HTTP_AUTHORIZATION' => unauthorized_credentials }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'includes correct next link in response headers'

      it 'JSON body response contains expected provider attributes' do
        json = JSON.parse(response.body)
        expect(json).to eq(
          [
            {
              'accrediting_provider' => 'Y',
              'campuses' => [
                {
                  'campus_code' => '-',
                  'name' => 'Main site 1',
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
              'recruitment_cycle' => '2019',
              'type_of_gt12' => 'Not coming',
              'utt_application_alerts' => 'Yes, required',
              'contacts' => [
                {
                  'type' => 'admin',
                  'name' => 'Admin Contact A123',
                  'email' => 'admin@acmescitt.education.uk',
                  'telephone' => '020 812 345 678'
                },
                {
                  'type' => 'utt',
                  'name' => 'Utt Contact A123',
                  'email' => 'utt@acmescitt.education.uk',
                  'telephone' => '020 812 345 678'
                },
                {
                  'type' => 'web_link',
                  'name' => 'Web Link Contact A123',
                  'email' => 'web_link@acmescitt.education.uk',
                  'telephone' => '020 812 345 678'
                },
                {
                  'type' => 'fraud',
                  'name' => 'Fraud Contact A123',
                  'email' => 'fraud@acmescitt.education.uk',
                  'telephone' => '020 812 345 678'
                },
                {
                  'type' => 'finance',
                  'name' => 'Finance Contact A123',
                  'email' => 'finance@acmescitt.education.uk',
                  'telephone' => '020 812 345 678'
                },
                {
                  'type' => 'application_alert_recipient',
                  'name' => '',
                  'email' => 'application_alert_recipient@acmescitt.education.uk',
                  'telephone' => ''
                }
              ]
            },
            {
              'accrediting_provider' => 'N',
              'campuses' => [
                {
                  'campus_code' => '-',
                  'name' => 'Main site 2',
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
              'recruitment_cycle' => '2019',
              'type_of_gt12' => 'Coming or Not',
              'utt_application_alerts' => 'No, not required',
              'contacts' => [
                {
                  'type' => 'admin',
                  'name' => 'Admin Contact B123',
                  'email' => 'admin@acmeuniversity.education.uk',
                  'telephone' => '01273 345 678'
                },
                {
                  'type' => 'utt',
                  'name' => 'Utt Contact B123',
                  'email' => 'utt@acmeuniversity.education.uk',
                  'telephone' => '01273 345 678'
                },
                {
                  'type' => 'web_link',
                  'name' => 'Web Link Contact B123',
                  'email' => 'web_link@acmeuniversity.education.uk',
                  'telephone' => '01273 345 678'
                },
                {
                  'type' => 'fraud',
                  'name' => 'Fraud Contact B123',
                  'email' => 'fraud@acmeuniversity.education.uk',
                  'telephone' => '01273 345 678'
                },
                {
                  'type' => 'finance',
                  'name' => 'Finance Contact B123',
                  'email' => 'finance@acmeuniversity.education.uk',
                  'telephone' => '01273 345 678'
                }
              ]
            }
          ]
        )
      end
    end

    context 'with multiple recruitment cycles' do
      describe 'JSON body response' do
        let(:provider) { create(:provider) }
        let(:provider2) { create(:provider, recruitment_cycle: next_cycle) }
        let(:next_cycle) { find_or_create(:recruitment_cycle, year: '2020') }

        before do
          provider
          provider2
          get_index
        end

        context 'with no cycle specified in the route' do
          let(:get_index) { get '/api/v1/providers', headers: { 'HTTP_AUTHORIZATION' => credentials } }

          it 'defaults to the current cycle when year' do
            returned_provider_codes = get_provider_codes_from_body(response.body)

            expect(returned_provider_codes).not_to include provider2.provider_code
            expect(returned_provider_codes).to include provider.provider_code
          end
        end
        context 'with a future recruitment cycle specified in the route' do
          let(:get_index) { get '/api/v1/2020/providers', headers: { 'HTTP_AUTHORIZATION' => credentials } }

          it 'only returns courses from the requested cycle' do
            returned_provider_codes = get_provider_codes_from_body(response.body)

            expect(returned_provider_codes).to include provider2.provider_code
            expect(returned_provider_codes).not_to include provider.provider_code
          end
        end
      end
    end

    context "with changed_since parameter" do
      describe "JSON body response" do
        it 'contains expected providers' do
          old_provider = create(:provider,
                                provider_code: "SINCE1",
                                changed_at: 1.hour.ago)

          updated_provider = create(:provider,
                                    provider_code: "SINCE2",
                                    changed_at: 5.minutes.ago)

          get '/api/v1/providers',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: { changed_since: 10.minutes.ago.utc.iso8601 }

          returned_provider_codes = get_provider_codes_from_body(response.body)

          expect(returned_provider_codes).not_to include old_provider.provider_code
          expect(returned_provider_codes).to include updated_provider.provider_code
        end
      end

      it 'includes correct next link in response headers' do
        create(:provider,
               provider_code: "LAST1",
               changed_at: 10.minutes.ago)

        timestamp_of_last_provider = 2.minutes.ago
        create(:provider,
               provider_code: "LAST2",
               changed_at: timestamp_of_last_provider)

        get '/api/v1/providers',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: 30.minutes.ago.utc.iso8601 }

        expect(response.headers).to have_key "Link"
        uri = URI.parse(response.headers["Link"].sub(/;.*/, ''))
        query_params = Rack::Utils.parse_query(uri.query).with_indifferent_access
        expect(query_params[:changed_since])
          .to eq timestamp_of_last_provider.utc.strftime('%FT%T.%6NZ')
        expect(query_params[:per_page]).to eq '100'
      end

      context 'with recruitment year specified in route' do
        it 'includes correct next link in response headers' do
          create(:provider,
                 provider_code: "LAST1",
                 changed_at: 10.minutes.ago)

          timestamp_of_last_provider = 2.minutes.ago
          create(:provider,
                 provider_code: "LAST2",
                 changed_at: timestamp_of_last_provider)

          get '/api/v1/providers?recruitment_year=2020',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: { changed_since: 30.minutes.ago.utc.iso8601 }


          expect(response.headers).to have_key "Link"
          url = url_for(
            recruitment_year: 2020,
            params: {
              changed_since: timestamp_of_last_provider.utc.strftime('%FT%T.%6NZ'),
              per_page: 100
            }
  )
          expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
        end
      end

      it 'includes correct next link when there is an empty set' do
        provided_timestamp = 5.minutes.ago.utc.iso8601

        get '/api/v1/providers',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: provided_timestamp }

        uri = URI.parse(response.headers["Link"].sub(/;.*/, ''))
        query_params = Rack::Utils.parse_query(uri.query).with_indifferent_access
        expect(query_params[:changed_since]).to eq provided_timestamp
      end



      def get_next_providers(link, params = {})
        get link,
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: params
      end

      context "with many providers" do
        before do
          @providers = Array.new(25) do |i|
            create(:provider, provider_code: "PROV#{i + 1}",
              changed_at: (30 - i).minutes.ago,
              sites: [],
              enrichments: [])
          end
        end

        it 'pages properly' do
          get_next_providers '/api/v1/providers', per_page: 10
          expect(response.body)
            .to have_providers(@providers[0..9])

          get_next_providers response.headers['Link'].split(';').first
          expect(response.body)
            .to have_providers(@providers[10..19])

          get_next_providers response.headers['Link'].split(';').first
          expect(response.body)
            .to have_providers(@providers[20..24])

          get_next_providers response.headers['Link'].split(';').first
          expect(response.body).to_not have_providers

          random_provider = Provider.all.sample
          random_provider.touch

          get_next_providers response.headers['Link'].split(';').first
          expect(response.body)
            .to have_providers([random_provider])
        end
      end

      context "with many providers updated in the same second" do
        timestamp = 1.second.ago
        before do
          @providers = Array.new(25) do |i|
            create(:provider, provider_code: "PROV#{i + 1}",
              changed_at: timestamp + i / 1000.0,
              sites: [],
              enrichments: [])
          end
        end

        it 'pages properly' do
          get_next_providers '/api/v1/providers', per_page: 10
          expect(response.body)
            .to have_providers(@providers[0..9])

          get_next_providers response.headers['Link'].split(';').first
          expect(response.body)
            .to have_providers(@providers[10..19])

          get_next_providers response.headers['Link'].split(';').first
          expect(response.body)
            .to have_providers(@providers[20..24])

          get_next_providers response.headers['Link'].split(';').first
          expect(response.body).to_not have_providers

          random_provider = Provider.all.sample
          random_provider.touch

          get_next_providers response.headers['Link'].split(';').first
          expect(response.body)
            .to have_providers([random_provider])
        end
      end
    end
  end
end
