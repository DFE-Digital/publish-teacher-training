require "rails_helper"

describe "Provider Publishable API v2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)     { create :provider, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe "POST publishable" do
    let(:publishable_path) do
      "/api/v2/recruitment_cycles/#{provider.recruitment_cycle.year}" +
        "/providers/#{provider.provider_code}/publishable"
    end

    let(:enrichment) { build(:provider_enrichment, :initial_draft) }

    subject do
      post publishable_path,
           headers: { "HTTP_AUTHORIZATION" => credentials },
           params: {
             _jsonapi: {
               data: {
                 attributes: {},
                 type: "provider",
               },
             },
           }
      response
    end

    include_examples "Unauthenticated, unauthorised, or not accepted T&Cs"

    context "provider with valid content" do
      let(:provider) {
        create(
          :provider,
          organisations: [organisation],
        )
      }

      it "returns ok" do
        expect(subject).to have_http_status(:success)
      end
    end

    describe "failed validation" do
      let(:json_data) { JSON.parse(subject.body)["errors"] }

      context "provider with invalid content lack_presence fields" do
        let(:provider) {
          create(
            :provider,
            organisations: [organisation],
            email: nil,
            train_with_us: nil,
            train_with_disability: nil,
          )
        }

        it { should have_http_status(:unprocessable_entity) }

        it "has validation error details" do
          expect(json_data.count).to eq 3
          expect(json_data[0]["detail"]).to eq("Enter an email address in the correct format, like name@example.com")
          expect(json_data[1]["detail"]).to eq("Enter details about training with you")
          expect(json_data[2]["detail"]).to eq("Enter details about training with a disability")
        end

        it "has validation error pointers" do
          expect(json_data[0]["source"]["pointer"]).to eq("/data/attributes/email")
          expect(json_data[1]["source"]["pointer"]).to eq("/data/attributes/train_with_us")
          expect(json_data[2]["source"]["pointer"]).to eq("/data/attributes/train_with_disability")
        end
      end
    end
  end
end
