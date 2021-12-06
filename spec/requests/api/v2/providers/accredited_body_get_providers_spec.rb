require "rails_helper"

describe "AccreditedBody API v2", type: :request do
  describe "GET /providers" do
    let(:user) { create(:user) }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:payload) { { email: user.email } }
    let(:credentials) { encode_to_credentials(payload) }

    let!(:course) do
      create(:course, provider: delivering_provider1, accrediting_provider: accredited_provider)
    end
    let!(:course2) do
      create(:course, provider: delivering_provider2, accrediting_provider: accredited_provider)
    end

    let(:delivering_provider1) { create(:provider, provider_name: "b") }
    let(:delivering_provider2) { create(:provider, provider_name: "c") }
    let(:accredited_provider) do
      create(:provider,
             provider_name: "a",
             provider_type: "lead_school",
             users: [user],
             recruitment_cycle: recruitment_cycle)
    end

    let(:json_response) { JSON.parse(response.body) }
    let(:request_path) { "/api/v2/recruitment_cycles/#{recruitment_cycle.year}/providers/#{accredited_provider.provider_code}/training_providers" }

    def perform_request
      get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    subject do
      perform_request

      response
    end

    it_behaves_like "Unauthenticated, unauthorised, or not accepted T&Cs"

    describe "JSON generated for a providers" do
      it "has a data section with the correct attributes" do
        perform_request

        expect(json_response).to eq(
          "data" => [
            {
              "id" => accredited_provider.id.to_s,
              "type" => "providers",
              "attributes" => {
                "provider_code" => accredited_provider.provider_code,
                "provider_name" => accredited_provider.provider_name,
                "provider_type" => accredited_provider.provider_type,
                "accredited_body?" => false,
                "accredited_bodies" => [],
                "train_with_us" => accredited_provider.train_with_us,
                "train_with_disability" => accredited_provider.train_with_disability,
                "latitude" => nil,
                "longitude" => nil,
                "address1" => accredited_provider.address1,
                "address2" => accredited_provider.address2,
                "address3" => accredited_provider.address3,
                "address4" => accredited_provider.address4,
                "postcode" => accredited_provider.postcode,
                "region_code" => "london",
                "telephone" => accredited_provider.telephone,
                "email" => accredited_provider.email,
                "website" => accredited_provider.website,
                "ukprn" => accredited_provider.ukprn,
                "urn" => accredited_provider.urn,
                "can_sponsor_skilled_worker_visa" => accredited_provider.can_sponsor_skilled_worker_visa,
                "can_sponsor_student_visa" => accredited_provider.can_sponsor_student_visa,
                "recruitment_cycle_year" => accredited_provider.recruitment_cycle.year,
                "gt12_contact" => nil,
                "application_alert_contact" => nil,
                "type_of_gt12" => nil,
                "send_application_alerts" => nil,
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
                    "count" => 0,
                  },
                },
              },
            },
            {
              "id" => delivering_provider1.id.to_s,
              "type" => "providers",
              "attributes" => {
                "provider_code" => delivering_provider1.provider_code,
                "provider_name" => delivering_provider1.provider_name,
                "provider_type" => accredited_provider.provider_type,
                "accredited_body?" => delivering_provider1.accredited_body?,
                "accredited_bodies" => [
                  {
                    "provider_name" => accredited_provider.provider_name,
                    "provider_code" => accredited_provider.provider_code,
                    "description" => "",
                  },
                ],
                "train_with_us" => delivering_provider1.train_with_us,
                "train_with_disability" => delivering_provider1.train_with_disability,
                "latitude" => delivering_provider1.latitude,
                "longitude" => delivering_provider1.longitude,
                "address1" => delivering_provider1.address1,
                "address2" => delivering_provider1.address2,
                "address3" => delivering_provider1.address3,
                "address4" => delivering_provider1.address4,
                "postcode" => delivering_provider1.postcode,
                "region_code" => delivering_provider1.region_code,
                "telephone" => delivering_provider1.telephone,
                "email" => delivering_provider1.email,
                "website" => delivering_provider1.website,
                "ukprn" => delivering_provider1.ukprn,
                "urn" => delivering_provider1.urn,
                "can_sponsor_skilled_worker_visa" => delivering_provider1.can_sponsor_skilled_worker_visa,
                "can_sponsor_student_visa" => delivering_provider1.can_sponsor_student_visa,
                "recruitment_cycle_year" => delivering_provider1.recruitment_cycle.year,
                "gt12_contact" => nil,
                "application_alert_contact" => nil,
                "type_of_gt12" => nil,
                "send_application_alerts" => nil,
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
                    "count" => 1,
                  },
                },
              },
            },
            {
              "id" => delivering_provider2.id.to_s,
              "type" => "providers",
              "attributes" => {
                "provider_code" => delivering_provider2.provider_code,
                "provider_name" => delivering_provider2.provider_name,
                "provider_type" => accredited_provider.provider_type,
                "accredited_body?" => delivering_provider2.accredited_body?,
                "accredited_bodies" => [
                  {
                    "provider_name" => accredited_provider.provider_name,
                    "provider_code" => accredited_provider.provider_code,
                    "description" => "",
                  },
                ],
                "train_with_us" => delivering_provider2.train_with_us,
                "train_with_disability" => delivering_provider2.train_with_disability,
                "latitude" => delivering_provider2.latitude,
                "longitude" => delivering_provider2.longitude,
                "address1" => delivering_provider2.address1,
                "address2" => delivering_provider2.address2,
                "address3" => delivering_provider2.address3,
                "address4" => delivering_provider2.address4,
                "postcode" => delivering_provider2.postcode,
                "region_code" => delivering_provider2.region_code,
                "telephone" => delivering_provider2.telephone,
                "email" => delivering_provider2.email,
                "website" => delivering_provider2.website,
                "ukprn" => delivering_provider2.ukprn,
                "urn" => delivering_provider2.urn,
                "can_sponsor_skilled_worker_visa" => delivering_provider2.can_sponsor_skilled_worker_visa,
                "can_sponsor_student_visa" => delivering_provider2.can_sponsor_student_visa,
                "recruitment_cycle_year" => delivering_provider2.recruitment_cycle.year,
                "gt12_contact" => nil,
                "application_alert_contact" => nil,
                "type_of_gt12" => nil,
                "send_application_alerts" => nil,
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
                    "count" => 1,
                  },
                },
              },
            },
          ],
          "meta" => {
            "accredited_courses_counts" => {
              delivering_provider1.provider_code.to_s => 1,
              accredited_provider.provider_code.to_s => 0,
              delivering_provider2.provider_code.to_s => 1,
            },
          },
          "jsonapi" => {
            "version" => "1.0",
          },
        )
      end
    end

    context "with two recruitment cycles" do
      let(:next_recruitment_cycle) { create :recruitment_cycle, :next }

      let!(:course3) { create(:course, provider: delivering_provider3, accrediting_provider: next_accredited_provider) }
      let(:delivering_provider3) { create(:provider, recruitment_cycle: next_recruitment_cycle) }

      let(:next_accredited_provider) {
        create :provider,
               users: [user],
               provider_code: accredited_provider.provider_code,
               recruitment_cycle: next_recruitment_cycle,
               year_code: next_recruitment_cycle.year
      }

      describe "making a request for the next recruitment cycle" do
        let(:request_path) {
          "/api/v2/recruitment_cycles/#{next_recruitment_cycle.year}/providers/#{accredited_provider.provider_code}/training_providers"
        }

        it "only returns data for the next recruitment cycle" do
          perform_request

          expect(json_response["data"].count).to eq 2
          expect(json_response["data"].first)
            .to have_attribute("recruitment_cycle_year")
            .with_value(next_recruitment_cycle.year)
        end
      end
    end
  end
end
