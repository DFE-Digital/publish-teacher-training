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
    ActionController::HttpAuthentication::Token
      .encode_credentials(token)
  end

  describe 'JSON generated for a user' do
    before do
      get "/api/v2/users/#{user.id}",
          headers: { 'HTTP_AUTHORIZATION' => credentials }
    end

    subject { response }

    it { should have_http_status(:success) }

    its(:body) { should be_json.with_content(data: { id: user.id.to_s }) }
    its(:body) { should be_json.with_content(data: { type: 'users' }) }
    its(:body) { should be_json.with_content(data: { attributes: { email: user.email } }) }
    its(:body) { should be_json.with_content(data: { attributes: { first_name: user.first_name } }) }
    its(:body) { should be_json.with_content(data: { attributes: { last_name: user.last_name } }) }
  end
end
