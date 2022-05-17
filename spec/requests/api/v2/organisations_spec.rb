require "rails_helper"

describe "Organisations API v2", type: :request do
  describe "GET /organisations" do
    let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:next_recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
    let(:user) { create(:user, :admin, organisations: [organisation]) }
    let(:user2) { create(:user) }
    let(:organisation) { create(:organisation, name: "Zeberdee") }
    let(:organisation2) { create(:organisation, name: "Aubrey", users: [user2]) }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:payload) { { email: user.email } }
    let(:credentials) { encode_to_credentials(payload) }

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

    context "when unauthenticated" do
      let(:payload) { { email: "foo@bar" } }

      it { is_expected.to have_http_status(:unauthorized) }
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

      it { is_expected.to have_http_status(:success) }

      context "with no params included" do
        before do
          organisation2
          perform_request
        end

        it "returns the organisations ordered by name" do
          organisations = json_response["data"]

          expect(organisations.count).to eq(2)
          expect(organisations.first["id"]).to eq(organisation2.id.to_s)
          expect(organisations.second["id"]).to eq(organisation.id.to_s)
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

        # PROTIP: if you get errors in the json matcher below that take long
        #         to generate (10s of seconds) and end up with a useless error
        #         about error? taking an argument, disable 'require
        #         "super_diff/rspec"' in spec_helper.rb

        it "returns the organisation resource" do
          expect(json_response["data"]).to include(have_id(organisation.id.to_s))
          expect(json_response["data"]).to include(have_type("organisations"))

          expect(json_response["data"]).to(
            include(have_attribute(:name).with_value(organisation.name)),
          )
        end

        it "returns the user relationships" do
          json_response["data"].each do |resource_data|
            expect(resource_data).to have_relationships("users")
          end

          returned_users = json_response["data"].map do |organisation_data|
            organisation_data["relationships"]["users"]["data"].first
          end

          expect(returned_users).to include have_id(user.id.to_s)
                                              .and(have_type("users"))
          expect(returned_users).to include have_id(user2.id.to_s)
                                              .and(have_type("users"))
          expect(json_response["included"]).to(
            include(
              have_type("users")
                .and(have_id(user.id.to_s))
                .and(have_attribute("email").with_value(user.email)),
              have_type("users")
                .and(have_id(user2.id.to_s))
                .and(have_attribute("email").with_value(user2.email)),
            ),
          )
        end

        it "returns the provider relationships" do
          json_response["data"].each do |resource_data|
            expect(resource_data).to have_relationships("providers")
          end

          returned_providers = json_response["data"].map do |organisation_data|
            organisation_data["relationships"]["providers"]["data"].first
          end

          expect(returned_providers).to include have_id(provider.id.to_s)
                                                  .and(have_type("providers"))
          expect(returned_providers).to include have_id(provider2.id.to_s)
                                                  .and(have_type("providers"))

          expect(json_response["included"]).to(
            include(
              have_type("providers")
                .and(have_id(provider.id.to_s))
                .and(have_attribute("provider_code")
                       .with_value(provider.provider_code)),
              have_type("providers")
                .and(have_id(provider2.id.to_s))
                .and(have_attribute("provider_code")
                       .with_value(provider2.provider_code)),
            ),
          )
        end
      end
    end
  end
end
