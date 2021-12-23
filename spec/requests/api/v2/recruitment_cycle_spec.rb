require "rails_helper"

describe "/api/v2/recruitment_cycle", type: :request do
  let(:user) { create(:user) }
  let(:json_response) { JSON.parse(response.body) }
  let(:payload) { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }
  let(:request_params) { {} }

  def perform_request
    get request_path,
        headers: { "HTTP_AUTHORIZATION" => credentials },
        params: request_params
  end

  describe "/api/v2/recruitment_cycles" do
    let(:recruitment_cycle)      { find_or_create :recruitment_cycle }
    let(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }
    let(:request_path) { "/api/v2/recruitment_cycles" }

    describe "the JSON response" do
      it "displays che correct jsonapi response" do
        next_recruitment_cycle

        perform_request

        expect(json_response)
          .to(eq(
                "data" => [
                  {
                    "id" => recruitment_cycle.id.to_s,
                    "type" => "recruitment_cycles",
                    "attributes" => {
                      "year" => recruitment_cycle.year,
                      "application_start_date" =>
                        recruitment_cycle.application_start_date.to_s,
                      "application_end_date" =>
                        recruitment_cycle.application_end_date.to_date.to_s,
                    },
                    "relationships" => {
                      "providers" => {
                        "meta" => {
                          "included" => false,
                        },
                      },
                    },
                  },
                  {
                    "id" => next_recruitment_cycle.id.to_s,
                    "type" => "recruitment_cycles",
                    "attributes" => {
                      "year" => next_recruitment_cycle.year,
                      "application_start_date" =>
                        next_recruitment_cycle.application_start_date.to_s,
                      "application_end_date" =>
                        next_recruitment_cycle.application_end_date.to_date.to_s,
                    },
                    "relationships" => {
                      "providers" => {
                        "meta" => {
                          "included" => false,
                        },
                      },
                    },
                  },
                ],
                "jsonapi" => {
                  "version" => "1.0",
                },
              ))
      end
    end
  end

  describe "/api/v2/recruitment_cycles/:year/providers/:provider_code/recruitment_cycles" do
    let(:recruitment_cycle)      { find_or_create :recruitment_cycle }
    let(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }
    let(:provider) { create :provider, users: [user] }
    let(:next_provider) {
      create :provider,
             :next_recruitment_cycle,
             users: [user],
             provider_code: provider.provider_code
    }
    let(:provider2) { create :provider }

    let(:request_path) {
      "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/recruitment_cycles"
    }

    describe "the JSON response" do
      it "displays the correct jsonapi response" do
        provider
        next_provider
        provider2

        perform_request

        json_response["data"].sort_by! { |cycle| cycle["attributes"]["year"] }

        expect(json_response)
          .to(eq(
                "data" => [
                  {
                    "id" => recruitment_cycle.id.to_s,
                    "type" => "recruitment_cycles",
                    "attributes" => {
                      "year" => recruitment_cycle.year,
                      "application_start_date" =>
                        recruitment_cycle.application_start_date.to_s,
                      "application_end_date" =>
                        recruitment_cycle.application_end_date.to_date.to_s,
                    },
                    "relationships" => {
                      "providers" => {
                        "meta" => {
                          "included" => false,
                        },
                      },
                    },
                  },
                  {
                    "id" => next_recruitment_cycle.id.to_s,
                    "type" => "recruitment_cycles",
                    "attributes" => {
                      "year" => next_recruitment_cycle.year,
                      "application_start_date" =>
                        next_recruitment_cycle.application_start_date.to_s,
                      "application_end_date" =>
                        next_recruitment_cycle.application_end_date.to_date.to_s,
                    },
                    "relationships" => {
                      "providers" => {
                        "meta" => {
                          "included" => false,
                        },
                      },
                    },
                  },
                ],
                "jsonapi" => {
                  "version" => "1.0",
                },
              ))
      end
    end
  end

  describe "/api/v2/recruitment_cycles/:year" do
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:request_params) { {} }
    let(:request_path) { "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" }

    let(:expected_response) {
      {
        "data" => {
          "id" => recruitment_cycle.id.to_s,
          "type" => "recruitment_cycles",
          "attributes" => {
            "year" => recruitment_cycle.year,
            "application_start_date" => recruitment_cycle.application_start_date.to_s,
            "application_end_date" => recruitment_cycle.application_end_date.to_date.to_s,
          },
          "relationships" => {
            "providers" => {
              "meta" => {
                "included" => false,
              },
            },
          },
        },
        "jsonapi" => {
          "version" => "1.0",
        },
      }
    }

    describe "the JSON response" do
      it "is the correct jsonapi response" do
        perform_request

        expect(json_response).to eq expected_response
      end
    end
  end
end
