require "rails_helper"

describe "Providers API v2", type: :request do
  describe "GET /providers" do
    let(:user) { create(:user) }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:payload) { { email: user.email } }
    let(:credentials) { encode_to_credentials(payload) }

    let!(:provider) {
      create(:provider,
             users: [user],
             contacts: [contact])
    }
    let(:contact) { build(:contact) }

    let(:json_response) { JSON.parse(response.body) }

    def perform_request
      get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    subject do
      perform_request

      response
    end

    context "when unauthorized" do
      let(:request_path) { "/api/v2/providers" }
      let(:payload)      { { email: "foo@bar" } }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    describe "JSON generated for providers" do
      let(:request_path) { "/api/v2/providers" }

      it "has a data section with the correct attributes" do
        perform_request

        expect(response).to have_http_status(:success)
        expect(json_response).to eq(
          "data" => [{
            "id" => provider.id.to_s,
            "type" => "providers",
            "attributes" => {
              "provider_code" => provider.provider_code,
              "provider_name" => provider.provider_name,
              "recruitment_cycle_year" => provider.recruitment_cycle.year,
            },
            "relationships" => {
              "courses" => {
                "meta" => {
                  "count" => provider.courses.count,
                },
              },
            },
          }],
          "meta" => {
            "count" => 1,
          },
          "jsonapi" => {
            "version" => "1.0",
          },
        )
      end
    end

    context "nested within current user" do
      let(:request_path) { "/api/v2/users/#{user.id}/providers" }

      it "has a data section with the correct attributes" do
        perform_request

        expect(json_response).to eq(
          "data" => [{
            "id" => provider.id.to_s,
            "type" => "providers",
            "attributes" => {
              "provider_code" => provider.provider_code,
              "provider_name" => provider.provider_name,
              "recruitment_cycle_year" => provider.recruitment_cycle.year,
            },
            "relationships" => {
              "courses" => {
                "meta" => {
                  "count" => provider.courses.count,
                },
              },
            },
          }],
          "meta" => {
            "count" => 1,
          },
          "jsonapi" => {
            "version" => "1.0",
          },
        )
      end
    end

    context "nested within a different user" do
      let(:different_user) { create(:user) }
      let(:request_path)   { "/api/v2/users/#{different_user.id}/providers" }

      it "has no providers" do
        perform_request

        expect(json_response).to eq(
          "data" => [],
          "meta" => {
            "count" => 0,
          },
          "jsonapi" => {
            "version" => "1.0",
          },
        )
      end
    end

    context "with unalphabetical ordering in the database" do
      let(:second_alphabetical_provider) do
        create(:provider, provider_name: "Zork", users: [user])
      end
      let(:provider_names_in_response) {
        JSON.parse(subject.body)["data"].map { |provider|
          provider["attributes"]["provider_name"]
        }
      }
      let(:request_path) { "/api/v2/users/#{user.id}/providers" }

      before do
        second_alphabetical_provider

        # This moves it last in the order that it gets fetched by default.
        provider.update(provider_name: "Acme")
      end

      it "returns them in alphabetical order" do
        expect(provider_names_in_response).to eq(%w[Acme Zork])
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
        let(:request_path) { "/api/v2/providers" }

        it "only returns data for the current recruitment cycle" do
          next_provider

          perform_request

          expect(json_response["data"].count).to eq 1
          expect(json_response["data"].first)
            .to have_attribute("recruitment_cycle_year")
                  .with_value(recruitment_cycle.year)
        end
      end

      describe "making a request for the next recruitment cycle" do
        let(:request_path) {
          "/api/v2/recruitment_cycles/#{next_recruitment_cycle.year}/providers"
        }

        it "only returns data for the next recruitment cycle" do
          next_provider

          perform_request

          expect(json_response["data"].count).to eq 1
          expect(json_response["data"].first)
            .to have_attribute("recruitment_cycle_year")
                  .with_value(next_recruitment_cycle.year)
        end
      end
    end
  end
end
