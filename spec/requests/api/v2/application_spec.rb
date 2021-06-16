require "rails_helper"

describe "API v2", type: :request do
  describe "Error 404" do
    let(:user) { create(:user, organisations: [organisation]) }
    let(:organisation) { create(:organisation) }
    let(:payload) { { email: user.email } }
    let(:credentials) { encode_to_credentials(payload) }

    subject { response }

    describe "when a provider is not found" do
      before do
        get "/api/v2/providers/foo", headers: { "HTTP_AUTHORIZATION" => credentials }
      end

      it { is_expected.to have_http_status(:not_found) }

      it "has a data section with the correct attributes" do
        json_response = JSON.parse(response.body)
        expect(json_response[:data]).to be_nil
      end
    end
  end
end
