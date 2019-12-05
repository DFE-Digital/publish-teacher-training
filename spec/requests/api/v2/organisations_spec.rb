require "rails_helper"

describe "Organisations API v2", type: :request do
  describe "GET /organistaions" do
    let(:user) { create(:user, :admin, organisations: [organisation]) }
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
             organisations: [organisation])
    }

    let(:request_path) { "/api/v2/organisations" }


    def perform_request
      get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    subject do
      perform_request
      response
    end

    context "when unauthenitcated" do
      let(:payload)      { { email: "foo@bar" } }

      it { should have_http_status(:unauthorized) }
    end

    context "when unauthorised" do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "raises an error" do
        expect {
          get "/api/v2/providers/#{provider.provider_code}/courses",
              headers: { "HTTP_AUTHORIZATION" => credentials }
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when authorised" do
      it { should have_http_status(:success) }
    end
  end
end
