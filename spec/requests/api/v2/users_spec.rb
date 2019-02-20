require "rails_helper"

describe '/api/v2/users', type: :request do
  let(:user)    { create(:user) }
  let(:payload) { { email: user.email } }
  let(:token) do
    JWT.encode payload.to_json,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  context 'when unauthenticated' do
    let(:payload) { { email: 'foo@bar' } }

    before do
      get "/api/v2/users/#{user.id}",
          headers: { 'HTTP_AUTHORIZATION' => credentials }
    end

    subject { response }

    it { should have_http_status(:unauthorized) }
  end

  context 'when unauthorized' do
    let(:unauthorised_user) { create(:user) }
    let(:payload) { { email: unauthorised_user.email } }

    it "raises an error" do
      expect {
        get "/api/v2/users/#{user.id}",
            headers: { 'HTTP_AUTHORIZATION' => credentials }
      }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe 'JSON generated for a user' do
    before do
      get "/api/v2/users/#{user.id}",
          headers: { 'HTTP_AUTHORIZATION' => credentials }
    end

    subject { response }

    it { should have_http_status(:success) }

    it 'has a data section with the correct attributes' do
      json_response = JSON.parse response.body
      expect(json_response).to eq(
        "data" => {
          "id" => user.id.to_s,
          "type" => "users",
          "attributes" => {
            "first_name" => user.first_name,
            "last_name" => user.last_name,
            "email" => user.email
          }
        },
        "jsonapi" => {
          "version" => "1.0"
        }
      )
    end
  end
end
