require "rails_helper"

describe 'Providers API v2', type: :request do
  describe 'GET /providers' do
    let(:user) { create(:user, organisations: [organisation]) }
    let(:organisation) { create(:organisation) }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:payload) { { email: user.email } }
    let(:token) do
      JWT.encode payload,
                 Settings.authentication.secret,
                 Settings.authentication.algorithm
    end
    let(:credentials) do
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    let!(:provider) {
      create(:provider,
             organisations: [organisation],
             enrichments: [enrichment])
    }
    let(:enrichment) { build(:provider_enrichment, :published) }

    let(:json_response) { JSON.parse(response.body) }

    def perform_request
      get request_path, headers: { 'HTTP_AUTHORIZATION' => credentials }
    end

    subject do
      perform_request

      response
    end

    context 'when unauthorized' do
      let(:request_path) { '/api/v2/providers' }
      let(:payload)      { { email: 'foo@bar' } }

      it { should have_http_status(:unauthorized) }
    end

    describe 'JSON generated for a providers' do
      let(:request_path) { '/api/v2/providers' }

      it { should have_http_status(:success) }

      it 'has a data section with the correct attributes' do
        perform_request

        expect(json_response).to eq(
          "data" => [{
            "id" => provider.id.to_s,
            "type" => "providers",
            "attributes" => {
              "provider_code" => provider.provider_code,
              "provider_name" => provider.provider_name,
              "recruitment_cycle_year" => provider.recruitment_cycle.year,
            },
            "relationships" => {
              "courses" => {
                "meta" => {
                  "count" => provider.courses.count
                }
              }
            }
          }],
          "jsonapi" => {
            "version" => "1.0"
          }
        )
      end
    end

    context 'nested within current user' do
      let(:request_path) { "/api/v2/users/#{user.id}/providers" }

      it 'has a data section with the correct attributes' do
        perform_request

        expect(json_response).to eq(
          "data" => [{
            "id" => provider.id.to_s,
            "type" => "providers",
            "attributes" => {
              "provider_code" => provider.provider_code,
              "provider_name" => provider.provider_name,
              "recruitment_cycle_year" => provider.recruitment_cycle.year,
            },
            "relationships" => {
              "courses" => {
                "meta" => {
                  "count" => provider.courses.count
                }
              }
            }
          }],
          "jsonapi" => {
            "version" => "1.0"
          }
        )
      end
    end

    context 'nested within a different user' do
      let(:different_user) { create(:user) }
      let(:request_path)   { "/api/v2/users/#{different_user.id}/providers" }

      it 'has no providers' do
        perform_request

        expect(json_response).to eq(
          "data" => [],
          "jsonapi" => {
            "version" => "1.0"
          }
        )
      end
    end

    context 'with unalphabetical ordering in the database' do
      let(:second_alphabetical_provider) do
        create(:provider, provider_name: 'Zork', organisations: [organisation])
      end
      let(:request_path) { "/api/v2/users/#{user.id}/providers" }

      before do
        second_alphabetical_provider

        # This moves it last in the order that it gets fetched by default.
        provider.update(provider_name: 'Acme')
      end

      let(:provider_names_in_response) {
        JSON.parse(subject.body)["data"].map { |provider|
          provider["attributes"]["provider_name"]
        }
      }

      it 'returns them in alphabetical order' do
        expect(provider_names_in_response).to eq(%w(Acme Zork))
      end
    end

    context 'with two recruitment cycles' do
      let(:next_recruitment_cycle) { create :recruitment_cycle, year: '2020' }
      let(:next_provider) {
        create :provider,
               organisations: [organisation],
               provider_code: provider.provider_code,
               recruitment_cycle: next_recruitment_cycle
      }

      describe 'making a request without specifying a recruitment cycle' do
        let(:request_path) { "/api/v2/providers" }

        it 'only returns data for the current recruitment cycle' do
          next_provider

          perform_request

          expect(json_response['data'].count).to eq 1
          expect(json_response['data'].first)
            .to have_attribute('recruitment_cycle_year').with_value('2019')
        end
      end

      describe 'making a request for the next recruitment cycle' do
        let(:request_path) {
          "/api/v2/recruitment_cycles/#{next_recruitment_cycle.year}/providers"
        }

        it 'only returns data for the next recruitment cycle' do
          next_provider

          perform_request

          expect(json_response['data'].count).to eq 1
          expect(json_response['data'].first)
            .to have_attribute('recruitment_cycle_year')
                  .with_value(next_recruitment_cycle.year)
        end
      end
    end
  end

  describe 'GET /providers#show' do
    let(:user) { create(:user, organisations: [organisation]) }
    let(:organisation) { create(:organisation) }
    let(:payload) { { email: user.email } }
    let(:token) do
      JWT.encode payload,
                 Settings.authentication.secret,
                 Settings.authentication.algorithm
    end
    let(:credentials) do
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    end
    let(:site) { build(:site) }
    let(:enrichment) { build(:provider_enrichment) }

    let!(:provider) { create(:provider, sites: [site], organisations: [organisation], enrichments: [enrichment]) }

    let(:request_params) { {} }

    subject do
      perform_request

      response
    end

    def perform_request
      get request_path,
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: request_params
    end

    let(:expected_response) {
      {
        "data" => {
          "id" => provider.id.to_s,
          "type" => "providers",
          "attributes" => {
            "provider_code" => provider.provider_code,
            "provider_name" => provider.provider_name,
            "accredited_body?" => false,
            "can_add_more_sites?" => true,
            "train_with_us" => enrichment.train_with_us,
            "train_with_disability" => enrichment.train_with_disability,
            "address1" => provider.address1,
            "address2" => provider.address2,
            "address3" => provider.address3,
            "address4" => provider.address4,
            "postcode" => provider.postcode,
            "region_code" => provider.region_code,
            "telephone" => provider.telephone,
            "email" => provider.email,
            "website" => provider.url,
            "recruitment_cycle_year" => provider.recruitment_cycle.year,
            "content_status" => provider.content_status.to_s,
            "last_published_at" => provider.last_published_at
          },
          "relationships" => {
            "sites" => {
              "meta" => {
                "included" => false
              }
            },
            "courses" => {
              "meta" => {
                "count" => provider.courses.count
              }
            }
          }
        },
        "jsonapi" => {
          "version" => "1.0"
        }
      }
    }
    let(:json_response) { JSON.parse(response.body) }

    context 'including sites' do
      let(:request_path) { "/api/v2/providers/#{provider.provider_code}" }
      let(:request_params) { { include: "sites" } }

      it { should have_http_status(:success) }

      it 'has a data section with the correct attributes' do
        perform_request

        expect(json_response).to eq(
          "data" => {
            "id" => provider.id.to_s,
            "type" => "providers",
            "attributes" => {
              "provider_code" => provider.provider_code,
              "provider_name" => provider.provider_name,
              "accredited_body?" => false,
              "can_add_more_sites?" => true,
              "train_with_us" => enrichment.train_with_us,
              "train_with_disability" => enrichment.train_with_disability,
              "address1" => provider.address1,
              "address2" => provider.address2,
              "address3" => provider.address3,
              "address4" => provider.address4,
              "postcode" => provider.postcode,
              "region_code" => provider.region_code,
              "telephone" => provider.telephone,
              "email" => provider.email,
              "website" => provider.url,
              "recruitment_cycle_year" => provider.recruitment_cycle.year,
              "content_status" => provider.content_status.to_s,
              "last_published_at" => provider.last_published_at,
            },
            "relationships" => {
              "sites" => {
                "data" => [
                  {
                    "type" => "sites",
                    "id" => site.id.to_s,
                  }
                ]
              },
              "courses" => {
                "meta" => {
                  "count" => provider.courses.count
                }
              }
            }
          },
          "included" => [
            {
              "id" => site.id.to_s,
              "type" => "sites",
              "attributes" => {
                "code" => site.code,
                "location_name" => site.location_name,
                "address1" => site.address1,
                "address2" => site.address2,
                "address3" => site.address3,
                "address4" => site.address4,
                "postcode" => site.postcode,
                "region_code" => site.region_code,
                "recruitment_cycle_year" => site.recruitment_cycle.year
              }
            }
          ],
          "jsonapi" => {
            "version" => "1.0"
          }
        )
      end
    end

    context "with the maximum number of sites" do
      let(:sites) {
        [*'A'..'Z', '0', '-', *'1'..'9'].map { |code|
          build(:site, code: code)
        }
      }
      let(:provider) { create(:provider, sites: sites, organisations: [organisation]) }
      let(:request_path) { "/api/v2/providers/#{provider.provider_code}" }

      it 'has can_add_more_sites? set to false' do
        perform_request

        expect(json_response['data'])
          .to have_attribute(:can_add_more_sites?).with_value(false)
      end
    end

    describe 'JSON generated for a provider' do
      let(:request_path) { "/api/v2/providers/#{provider.provider_code}" }

      it { should have_http_status(:success) }

      it 'has a data section with the correct attributes' do
        perform_request

        expect(json_response).to eq(expected_response)
      end
    end

    describe "with lowercase provider code" do
      let(:request_path) { "/api/v2/providers/#{provider.provider_code.downcase}" }

      it { should have_http_status(:success) }

      it 'has a data section with the correct attributes' do
        perform_request

        expect(json_response).to eq(expected_response)
      end
    end

    context 'with two recruitment cycles' do
      let(:next_recruitment_cycle) { create :recruitment_cycle, year: '2020' }
      let(:next_provider) {
        create :provider,
               organisations: [organisation],
               provider_code: provider.provider_code,
               recruitment_cycle: next_recruitment_cycle
      }

      describe 'making a request without specifying a recruitment cycle' do
        let(:request_path) { "/api/v2/providers/#{provider.provider_code.downcase}" }

        it 'only returns data for the current recruitment cycle' do
          next_provider

          perform_request

          expect(json_response['data'])
            .to have_attribute('recruitment_cycle_year')
                  .with_value(provider.recruitment_cycle.year)
          expect(json_response['data'])
            .to have_attribute('provider_code')
                  .with_value(provider.provider_code)
        end
      end

      describe 'making a request for the next recruitment cycle' do
        let(:request_path) {
          "/api/v2/recruitment_cycles/#{next_recruitment_cycle.year}" \
          "/providers/#{next_provider.provider_code}"
        }

        it 'only returns data for the next recruitment cycle' do
          next_provider

          perform_request

          expect(json_response['data'])
            .to have_attribute('recruitment_cycle_year')
                  .with_value(next_recruitment_cycle.year)
          expect(json_response['data'])
            .to have_attribute('provider_code')
                  .with_value(next_provider.provider_code)
        end
      end
    end
  end
end
