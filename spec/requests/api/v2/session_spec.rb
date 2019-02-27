require "rails_helper"

describe '/api/v2/session', type: :request do
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

  describe 'creating a session' do
    let(:user)    { create(:user, last_login_date_utc: 10.days.ago) }
    it 'saves the last login time' do
      Timecop.freeze do
        post '/api/v2/session',
             headers: { 'HTTP_AUTHORIZATION' => credentials }

        # OS vs TimeCop vs db, most likely db (nanoseconds are omitted), hence
        # 'be_within(1.second).of Time.now.utc' vs 'eq Time.now.utc'
        expect(user.reload.last_login_date_utc).to be_within(1.second).of Time.now.utc
      end
    end

    it 'returns the user record' do
      post '/api/v2/session',
           headers: { 'HTTP_AUTHORIZATION' => credentials },
           params: { first_name: user.first_name, last_name: user.last_name }

      json_response = JSON.parse response.body
      expect(json_response).to eq(
        "data" => {
          "id" => user.id.to_s,
          "type" => "users",
          "attributes" => {
            "first_name" => user.first_name,
            "last_name" => user.last_name,
            "email" => user.email,
          }
        },
          "jsonapi" => {
            "version" => "1.0"
          }
        )
    end

    it 'returns the updated user record' do
      post '/api/v2/session',
           headers: { 'HTTP_AUTHORIZATION' => credentials },
           params: { first_name: "updated first_name", last_name: "updated last_name" }

      json_response = JSON.parse response.body
      expect(json_response).to eq(
        "data" => {
          "id" => user.id.to_s,
          "type" => "users",
          "attributes" => {
            "first_name" => "updated first_name",
            "last_name" => "updated last_name",
            "email" => user.email,
          }
        },
          "jsonapi" => {
            "version" => "1.0"
          }
        )
      user.reload
      expect(user.first_name).to eq "updated first_name"
      expect(user.last_name).to eq "updated last_name"
    end
  end
end
