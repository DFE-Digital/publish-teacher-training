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

  before do
    get "/api/v2/users/#{user.id}",
        headers: { 'HTTP_AUTHORIZATION' => credentials }
  end

  subject { response }

  its(:status) { should eq 200 }
  its(:body)   { should be_json }
  its(:body)   { should be_json.with_content(data: { id: user.id.to_s }) }
end
