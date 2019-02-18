require 'rails_helper'

describe 'Courses API v2', type: :request do
  describe 'GET index' do
    let(:user) { create(:user) }
    let(:payload) { { email: user.email } }
    let(:token) do
      JWT.encode payload.to_json,
                 Settings.authentication.secret,
                 Settings.authentication.algorithm
    end
    let(:credentials) do
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    let(:provider) { create :provider }
    subject { response }

    before do
      get "/api/v2/providers/#{provider.provider_code}/courses",
          headers: { 'HTTP_AUTHORIZATION' => credentials }
    end

    context 'when unauthorized' do
      let(:payload) { { email: 'foo@bar' } }

      it { should have_http_status(:unauthorized) }
    end

    describe 'JSON generated for courses' do
      it { should have_http_status(:success) }
    end

    it "raises a record not found error when the provider doesn't exist" do
      expect {
        get("/api/v2/providers/non-existent-provider/courses",
         headers: { 'HTTP_AUTHORIZATION' => credentials })
      } .to raise_error ActiveRecord::RecordNotFound
    end
  end
end
