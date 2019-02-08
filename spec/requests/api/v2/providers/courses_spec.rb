require 'rails_helper'

describe 'Courses API v2', type: :request do
  describe 'GET index' do
    let(:user) { create(:user) }
    let(:payload) { { email: user.email } }
    let(:encoded_token) do
      JWT.encode payload.to_json,
                 Settings.authentication.secret,
                 Settings.authentication.algorithm
    end
    let(:bearer_token) { "Bearer #{encoded_token}" }

    let(:provider) { create :provider }

    it 'returns http success' do
      get "/api/v2/providers/#{provider.provider_code}/courses", headers: { 'HTTP_AUTHORIZATION' => bearer_token }
      expect(response).to have_http_status(:success)
    end

    it 'returns http unauthorised' do
      get "/api/v2/providers/#{provider.provider_code}/courses",
          headers: { 'HTTP_AUTHORIZATION' => 'no bearer_token' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'raise a a record not found error' do
      expect {
        get("/api/v2/providers/garabage/courses",
         headers: { 'HTTP_AUTHORIZATION' => bearer_token })
      } .to raise_error ActiveRecord::RecordNotFound
    end
  end
end
