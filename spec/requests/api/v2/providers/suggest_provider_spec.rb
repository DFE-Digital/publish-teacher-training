require 'rails_helper'

describe 'GET /suggest' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:organisation) { create(:organisation) }
  let(:provider) { create(:provider, organisations: [organisation]) }
  let(:unauthorized_provider) { create(:provider, organisations: [create(:organisation)]) }
  let(:user) { create :user, organisations: [organisation] }
  let(:payload) { { email: user.email } }
  let(:token) { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  it 'gets all providers for a user' do
    provider
    unauthorized_provider
    get '/api/v2/providers/suggest',
        headers: { 'HTTP_AUTHORIZATION' => credentials }

    expect(JSON.parse(response.body)['data']).to eq([
      {
        'id' => provider.id.to_s,
        'type' => 'provider',
        'attributes' => {
          'provider_code' => provider.provider_code,
          'provider_name' => provider.provider_name
        }
      }
    ])
  end
end
