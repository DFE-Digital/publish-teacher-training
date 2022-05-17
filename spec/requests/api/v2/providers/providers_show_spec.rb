require "rails_helper"

describe "Providers API v2", type: :request do
  describe "GET /providers#show" do
    let(:request_path) { "/api/v2/providers/#{provider.provider_code}" }
    let(:request_params) { {} }
    let(:user) { create(:user) }
    let(:payload) { { email: user.email } }
    let(:credentials) { encode_to_credentials(payload) }

    let(:site) { build(:site) }
    let(:description) { "An accredited body description" }
    let(:accrediting_provider_enrichments) do
      [{
        "UcasProviderCode" => accrediting_provider.provider_code,
        "Description" => description,
      }]
    end
    let(:accrediting_provider) { create :provider }
    let(:course) { create :course, accrediting_provider: accrediting_provider }
    let(:courses) { [course] }
    let!(:provider) do
      create(:provider,
             :accredited_body,
             sites: [site],
             users: [user],
             accrediting_provider_enrichments: accrediting_provider_enrichments,
             courses: courses,
             contacts: [contact],
             ucas_preferences: ucas_preferences)
    end
    let(:contact) { build(:contact) }
    let(:ucas_preferences) { build(:provider_ucas_preference) }

    let(:expected_response) {
      {
        "data" => {
          "id" => provider.id.to_s,
          "type" => "providers",
          "attributes" => {
            "provider_code" => provider.provider_code,
            "provider_name" => provider.provider_name,
            "provider_type" => provider.provider_type,
            "accredited_body?" => true,
            "train_with_us" => provider.train_with_us,
            "train_with_disability" => provider.train_with_disability,
            "address1" => provider.address1,
            "address2" => provider.address2,
            "address3" => provider.address3,
            "address4" => provider.address4,
            "postcode" => provider.postcode,
            "region_code" => provider.region_code,
            "latitude" => provider.latitude,
            "longitude" => provider.longitude,
            "telephone" => provider.telephone,
            "email" => provider.email,
            "website" => provider.website,
            "ukprn" => provider.ukprn,
            "urn" => provider.urn,
            "can_sponsor_skilled_worker_visa" => provider.can_sponsor_skilled_worker_visa,
            "can_sponsor_student_visa" => provider.can_sponsor_student_visa,
            "recruitment_cycle_year" => provider.recruitment_cycle.year,
            "accredited_bodies" => [{
              "provider_code" => accrediting_provider.provider_code,
              "provider_name" => accrediting_provider.provider_name,
              "description" => description,
            }],
            "gt12_contact" => provider.ucas_preferences.gt12_response_destination.to_s,
            "application_alert_contact" => provider.ucas_preferences.application_alert_email,
            "type_of_gt12" => provider.ucas_preferences.type_of_gt12.to_s,
            "send_application_alerts" => provider.ucas_preferences.send_application_alerts,
          },
          "relationships" => {
            "sites" => {
              "meta" => {
                "included" => false,
              },
            },
            "users" => {
              "meta" => {
                "included" => false,
              },
            },
            "contacts" => {
              "meta" => {
                "included" => false,
              },
            },
            "courses" => {
              "meta" => {
                "count" => provider.courses.count,
              },
            },
          },
        },
        "jsonapi" => {
          "version" => "1.0",
        },
      }
    }

    let(:json_response) { JSON.parse(response.body) }

    subject do
      perform_request
      response
    end

    def perform_request
      get request_path,
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: request_params
    end

    context "including users" do
      let(:request_params) { { include: "users" } }

      it "has a included user section with the correct attributes" do
        perform_request

        expect(response).to have_http_status(:success)
        included_user = json_response["included"].first

        expect(included_user["id"]).to eq(user.id.to_s)
        expect(included_user["type"]).to eq("users")
        expect(included_user["attributes"]["first_name"]).to eq(user.first_name)
        expect(included_user["attributes"]["last_name"]).to eq(user.last_name)
        expect(included_user["attributes"]["email"]).to eq(user.email)
      end
    end

    context "including sites" do
      let(:request_params) { { include: "sites" } }

      it "has a included site section with the correct attributes" do
        perform_request

        expect(response).to have_http_status(:success)
        included_site = json_response["included"].first

        expect(included_site["id"]).to eq(site.id.to_s)
        expect(included_site["type"]).to eq("sites")
        expect(included_site["attributes"]["code"]).to eq(site.code)
        expect(included_site["attributes"]["location_name"]).to eq(site.location_name)
        expect(included_site["attributes"]["address1"]).to eq(site.address1)
        expect(included_site["attributes"]["address2"]).to eq(site.address2)
        expect(included_site["attributes"]["address3"]).to eq(site.address3)
        expect(included_site["attributes"]["address4"]).to eq(site.address4)
        expect(included_site["attributes"]["postcode"]).to eq(site.postcode)
        expect(included_site["attributes"]["region_code"]).to eq(site.region_code)
        expect(included_site["attributes"]["latitude"]).to eq(site.latitude)
        expect(included_site["attributes"]["longitude"]).to eq(site.longitude)
        expect(included_site["attributes"]["recruitment_cycle_year"]).to eq(site.recruitment_cycle.year)
      end
    end

    describe "JSON generated for a provider" do
      it "has a data section with the correct attributes" do
        perform_request

        expect(response).to have_http_status(:success)
        expect(json_response).to eq(expected_response)
      end
    end

    describe "with lowercase provider code" do
      let(:request_path) { "/api/v2/providers/#{provider.provider_code.downcase}" }

      it "has a data section with the correct attributes" do
        perform_request

        expect(response).to have_http_status(:success)
        expect(json_response).to eq(expected_response)
      end
    end

    context "with two recruitment cycles" do
      let(:next_recruitment_cycle) { create :recruitment_cycle, :next }
      let(:next_provider) {
        create :provider,
               users: [user],
               provider_code: provider.provider_code,
               recruitment_cycle: next_recruitment_cycle
      }

      describe "making a request without specifying a recruitment cycle" do
        it "only returns data for the current recruitment cycle" do
          next_provider

          perform_request

          expect(json_response["data"])
            .to have_attribute("recruitment_cycle_year")
                  .with_value(provider.recruitment_cycle.year)
          expect(json_response["data"])
            .to have_attribute("provider_code")
                  .with_value(provider.provider_code)
        end
      end

      describe "making a request for the next recruitment cycle" do
        let(:request_path) {
          "/api/v2/recruitment_cycles/#{next_recruitment_cycle.year}" \
            "/providers/#{next_provider.provider_code}"
        }

        it "only returns data for the next recruitment cycle" do
          next_provider

          perform_request

          expect(json_response["data"])
            .to have_attribute("recruitment_cycle_year")
                  .with_value(next_recruitment_cycle.year)
          expect(json_response["data"])
            .to have_attribute("provider_code")
                  .with_value(next_provider.provider_code)
        end
      end
    end
  end
end
