require "rails_helper"

describe "Organisations API v2", type: :request do
  describe "GET /organistaions" do
    let(:user) { create(:user, :admin, organisations: [organisation]) }
    let(:user2) { create(:user) }
    let(:organisation) { create(:organisation, name: "Z Teach") }
    let(:organisation2) { create(:organisation, name: "A Teach", users: [user2]) }
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
    let(:provider2) { create(:provider, organisations: [organisation2]) }

    let(:request_path) { "/api/v2/organisations" }
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
          get "/api/v2/providers/#{provider.provider_code}/courses",
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
                  "id" => organisation2.id.to_s,
                  "type" => "organisations",
                  "attributes" => {
                    "name" => organisation2.name,
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
                   "id" => organisation.id.to_s,
                   "type" => "organisations",
                   "attributes" => {
                     "name" => organisation.name,
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
          provider2
          perform_request
        end

        it "has a JSON data section with the correct attributes" do
          expect(json_response).to eq(
            "data" => [
              {
                "id" => organisation2.id.to_s,
                "type" => "organisations",
                "attributes" => {
                  "name" => organisation2.name,
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
              {
                "id" => organisation.id.to_s,
                "type" => "organisations",
                "attributes" => {
                  "name" => organisation.name,
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
            ],
             "included" => [
               {
                 "id" => user2.id.to_s,
                 "type" => "users",
                 "attributes" => {
                   "first_name" => user2.first_name,
                   "last_name" => user2.last_name,
                   "email" => user2.email,
                   "accept_terms_date_utc" => user2.accept_terms_date_utc.utc.strftime("%FT%T.%3NZ"),
                   "state" => user2.state,
                   "admin" => user2.admin,
                 },
                 "relationships" => {
                   "organisations" => {
                     "meta" => {
                       "included" => false,
                     },
                   },
                 },
               },
               {
                 "id" => provider2.id.to_s,
                 "type" => "providers",
                 "attributes" => {
                   "provider_code" => provider2.provider_code,
                   "provider_name" => provider2.provider_name,
                   "accredited_body?" => provider2.accredited_body?,
                   "can_add_more_sites?" => provider2.can_add_more_sites?,
                   "content_status" => provider2.content_status.to_s,
                   "accredited_bodies" => provider2.accredited_bodies,
                   "train_with_us" => provider2.train_with_us,
                   "train_with_disability" => provider2.train_with_disability,
                   "address1" => provider2.address1,
                   "address2" => provider2.address2,
                   "address3" => provider2.address3,
                   "address4" => provider2.address4,
                   "postcode" => provider2.postcode,
                   "region_code" => provider2.region_code,
                   "telephone" => provider2.telephone,
                   "email" => provider2.email,
                   "website" => provider2.website,
                   "recruitment_cycle_year" => provider2.recruitment_cycle.year,
                   "last_published_at" => provider2.last_published_at,
                   "admin_contact" => provider2.ucas_preferences&.admin_contact,
                   "utt_contact" => provider2.ucas_preferences&.utt_contact,
                   "web_link_contact" => provider2.ucas_preferences&.web_link_contact,
                   "fraud_contact" => provider2.ucas_preferences&.fraud_contact,
                   "finance_contact" => provider2.ucas_preferences&.finance_contact,
                   "gt12_contact" => provider2.ucas_preferences&.gt12_contact,
                   "application_alert_contact" => provider2.ucas_preferences&.application_alert_contact,
                   "type_of_gt12" => provider2.ucas_preferences&.type_of_gt12,
                   "send_application_alerts" => provider2.ucas_preferences&.send_application_alerts,
                 },
                 "relationships" => {
                   "sites" => {
                     "meta" => {
                       "included" => false,
                     },
                   },
                   "courses" => {
                     "meta" => {
                       "count" => 0,
                     },
                   },
                 },
               },
               {
                 "id" => user.id.to_s,
                 "type" => "users",
                 "attributes" => {
                   "first_name" => user.first_name,
                   "last_name" => user.last_name,
                   "email" => user.email,
                   "accept_terms_date_utc" => user.accept_terms_date_utc.utc.strftime("%FT%T.%3NZ"),
                   "state" => user.state,
                   "admin" => user.admin,
                 },
                 "relationships" => {
                   "organisations" => {
                     "meta" => {
                       "included" => false,
                     },
                   },
                 },
               },
               {
                 "id" => provider.id.to_s,
                 "type" => "providers",
                 "attributes" => {
                   "provider_code" => provider.provider_code,
                   "provider_name" => provider.provider_name,
                   "accredited_body?" => provider.accredited_body?,
                   "can_add_more_sites?" => provider.can_add_more_sites?,
                   "content_status" => provider.content_status.to_s,
                   "accredited_bodies" => provider.accredited_bodies,
                   "train_with_us" => provider.train_with_us,
                   "train_with_disability" => provider.train_with_disability,
                   "address1" => provider.address1,
                   "address2" => provider.address2,
                   "address3" => provider.address3,
                   "address4" => provider.address4,
                   "postcode" => provider.postcode,
                   "region_code" => provider.region_code,
                   "telephone" => provider.telephone,
                   "email" => provider.email,
                   "website" => provider.website,
                   "recruitment_cycle_year" => provider.recruitment_cycle.year,
                   "last_published_at" => provider.last_published_at,
                   "admin_contact" => provider.ucas_preferences&.admin_contact,
                   "utt_contact" => provider.ucas_preferences&.utt_contact,
                   "web_link_contact" => provider.ucas_preferences&.web_link_contact,
                   "fraud_contact" => provider.ucas_preferences&.fraud_contact,
                   "finance_contact" => provider.ucas_preferences&.finance_contact,
                   "gt12_contact" => provider.ucas_preferences&.gt12_contact,
                   "application_alert_contact" => provider.ucas_preferences&.application_alert_contact,
                   "type_of_gt12" => provider.ucas_preferences&.type_of_gt12,
                   "send_application_alerts" => provider.ucas_preferences&.send_application_alerts,
                 },
                 "relationships" => {
                   "sites" => {
                     "meta" => {
                       "included" => false,
                     },
                   },
                   "courses" => {
                     "meta" => {
                       "count" => 0,
                     },
                   },
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
