require "rails_helper"

describe "Organisations API v2", type: :request do
  describe "GET /organistaions" do
    let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:next_recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
    let(:user) { create(:user, :admin, organisations: [organisation]) }
    let(:user2) { create(:user) }
    let(:organisation) { create(:organisation) }
    let(:organisation2) { create(:organisation, users: [user2]) }
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

    let!(:provider) do
      create(:provider,
             organisations: [organisation])
    end
    let(:provider2) { create(:provider, organisations: [organisation2]) }
    let(:provider3) { create(:provider, recruitment_cycle: next_recruitment_cycle, organisations: [organisation]) }

    let(:request_path) { "/api/v2/recruitment_cycles/#{current_recruitment_cycle.year}/organisations" }
    let(:request_params) { {} }

    def perform_request
      get request_path,
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: request_params
    end

    subject do
      perform_request
      response
    end

    context "when unauthenitcated" do
      let(:payload) { { email: "foo@bar" } }

      it { should have_http_status(:unauthorized) }
    end

    context "when unauthorised" do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "raises an error" do
        expect {
          get request_path,
              headers: { "HTTP_AUTHORIZATION" => credentials }
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when authorised" do
      let(:json_response) { JSON.parse(response.body) }
      it { should have_http_status(:success) }

      context "with no params included" do
        before do
          organisation2
          perform_request
        end

        it "has a JSON data section with the correct attributes" do
          expect(json_response).to eq(
            "data" =>
                [{
                  "id" => organisation.id.to_s,
                  "type" => "organisations",
                  "attributes" => {
                    "name" => organisation.name,
                    "nctl_ids" => organisation.nctl_organisations.map(&:nctl_id),
                  },
                  "relationships" => {
                    "users" => {
                      "meta" => {
                        "included" => false,
                        },
                      },
                    "providers" => {
                      "meta" => {
                        "included" => false,
                       },
                     },
                    },
                  },
                 {
                   "id" => organisation2.id.to_s,
                   "type" => "organisations",
                   "attributes" => {
                     "name" => organisation2.name,
                     "nctl_ids" => organisation2.nctl_organisations.map(&:nctl_id),
                   },
                 "relationships" => {
                   "users" => {
                     "meta" => {
                       "included" => false,
                       },
                     },
                     "providers" => {
                       "meta" => {
                         "included" => false,
                       },
                     },
                   },
                 }],
                "jsonapi" => {
                  "version" => "1.0",
                },
              )
        end
      end

      context "with request params" do
        let(:request_params) { { include: "providers,users" } }

        before do
          user
          provider2
          provider3
          perform_request
        end

        it "returns includes only essential data for users and the providers from the current cycle" do
          expect(json_response).to eq(
            "data" => [
              {
                "id" => organisation.id.to_s,
                "type" => "organisations",
                "attributes" => {
                  "name" => organisation.name,
                  "nctl_ids" => organisation.nctl_organisations.map(&:nctl_id),
                },
                "relationships" => {
                  "users" => {
                     "data" => [
                       {
                         "type" => "users",
                         "id" => user.id.to_s,
                       },
                     ],
                  },
                   "providers" => {
                     "data" => [
                       {
                         "type" => "providers",
                         "id" => provider.id.to_s,

                       },
                     ],
                   },
                },
              },
              {
                "id" => organisation2.id.to_s,
                "type" => "organisations",
                "attributes" => {
                  "name" => organisation2.name,
                  "nctl_ids" => organisation2.nctl_organisations.map(&:nctl_id),
                },
                "relationships" => {
                  "users" => {
                     "data" => [
                       {
                         "type" => "users",
                         "id" => user2.id.to_s,
                       },
                     ],
                  },
                   "providers" => {
                     "data" => [
                       {
                         "type" => "providers",
                         "id" => provider2.id.to_s,
                       },
                     ],
                   },
                },
              },
            ],
             "included" => [
               {
                 "id" => user.id.to_s,
                 "type" => "users",
                 "attributes" => {
                   "first_name" => user.first_name,
                   "last_name" => user.last_name,
                   "email" => user.email,
                   "sign_in_user_id" => nil,
                 },
               },
               {
                 "id" => provider.id.to_s,
                 "type" => "providers",
                 "attributes" => {
                   "provider_code" => provider.provider_code,
                   "provider_name" => provider.provider_name,
                 },
               },
               {
                 "id" => user2.id.to_s,
                 "type" => "users",
                 "attributes" => {
                   "first_name" => user2.first_name,
                   "last_name" => user2.last_name,
                   "email" => user2.email,
                   "sign_in_user_id" => user2.sign_in_user_id,
                 },
               },
               {
                 "id" => provider2.id.to_s,
                 "type" => "providers",
                 "attributes" => {
                   "provider_code" => provider2.provider_code,
                   "provider_name" => provider2.provider_name,
                 },
               },
             ],
            "jsonapi" => {
              "version" => "1.0",
            },
         )
        end
      end
    end
  end
end
