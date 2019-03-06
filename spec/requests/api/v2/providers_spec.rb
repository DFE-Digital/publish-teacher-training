require "rails_helper"

describe 'Providers API v2', type: :request do
  describe 'GET /providers' do
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

    let!(:provider) { create(:provider, course_count: 0, site_count: 0, organisations: [organisation]) }

    subject { response }

    context 'when unauthorized' do
      before do
        get '/api/v2/providers', headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      let(:payload) { { email: 'foo@bar' } }

      it { should have_http_status(:unauthorized) }
    end

    describe 'JSON generated for a providers' do
      before do
        get '/api/v2/providers', headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      it { should have_http_status(:success) }

      it 'has a data section with the correct attributes' do
        json_response = JSON.parse(response.body)
        expect(json_response).to eq(
          "data" => [{
            "id" => provider.id.to_s,
            "type" => "providers",
            "attributes" => {
              "institution_code" => provider.provider_code,
              "institution_name" => provider.provider_name
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
      before do
        get "/api/v2/users/#{user.id}/providers", headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      it 'has a data section with the correct attributes' do
        json_response = JSON.parse(response.body)
        expect(json_response).to eq(
          "data" => [{
            "id" => provider.id.to_s,
            "type" => "providers",
            "attributes" => {
              "institution_code" => provider.provider_code,
              "institution_name" => provider.provider_name
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
      before do
        get "/api/v2/users/#{different_user.id}/providers", headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      it 'has no providers' do
        json_response = JSON.parse(response.body)
        expect(json_response).to eq(
          "data" => [],
          "jsonapi" => {
            "version" => "1.0"
          }
        )
      end
    end

    context 'with unalphabetical ordering in the database' do
      let!(:second_alphabetical_provider) { create(:provider, provider_name: 'Zork', organisations: [organisation]) }

      before do
        provider.update(provider_name: 'Acme') # This moves it last in the order that it gets fetched by default.
        get "/api/v2/users/#{user.id}/providers", headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      let(:provider_names_in_response) {
        JSON.parse(response.body)["data"].map { |provider| provider["attributes"]["institution_name"] }
      }

      it 'returns them in alphabetical order' do
        expect(provider_names_in_response).to eq(%w(Acme Zork))
      end
    end
  end
end
