require "rails_helper"

describe "GET v3/recruitment_cycle/:recruitment_cycle_year/providers/:provider_code" do
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers/#{provider.provider_code}" }
  let(:request_params) { {} }

  let(:user) { create(:user, organisations: [organisation]) }
  let(:organisation) { create(:organisation) }
  let(:payload) { { email: user.email } }

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
           sites: [site],
           organisations: [organisation],
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
          "accredited_body?" => false,
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
          "accredited_bodies" => [{
            "provider_code" => accrediting_provider.provider_code,
            "provider_name" => accrediting_provider.provider_name,
            "description" => description,
          }],
        },
        "relationships" => {
          "sites" => {
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
    get request_path, params: request_params
  end

  context "including sites" do
    let(:request_params) { { include: "sites" } }

    it { should have_http_status(:success) }

    it "has a data section with the correct attributes" do
      perform_request

      expect(json_response).to eq(
        "data" => {
          "id" => provider.id.to_s,
          "type" => "providers",
          "attributes" => {
            "provider_code" => provider.provider_code,
            "provider_name" => provider.provider_name,
            "accredited_body?" => false,
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
            "accredited_bodies" => [{
              "provider_code" => accrediting_provider.provider_code,
              "provider_name" => accrediting_provider.provider_name,
              "description" => description,
            }],
          },
          "relationships" => {
            "sites" => {
              "data" => [
                {
                  "type" => "sites",
                  "id" => site.id.to_s,
                },
              ],
            },
            "courses" => {
              "meta" => {
                "count" => provider.courses.count,
              },
            },
          },
        },
        "included" => [
          {
            "id" => site.id.to_s,
            "type" => "sites",
            "attributes" => {
              "code" => site.code,
              "location_name" => site.location_name,
              "address1" => site.address1,
              "address2" => site.address2,
              "address3" => site.address3,
              "address4" => site.address4,
              "postcode" => site.postcode,
              "region_code" => site.region_code,
              "latitude" => site.latitude,
              "longitude" => site.longitude,
              "recruitment_cycle_year" => site.recruitment_cycle.year,
            },
          },
        ],
        "jsonapi" => {
          "version" => "1.0",
        },
      )
    end
  end

  describe "JSON generated for a provider" do
    it { should have_http_status(:success) }

    it "has a data section with the correct attributes" do
      perform_request

      expect(json_response).to eq(expected_response)
    end
  end

  describe "with lowercase provider code" do
    let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers/#{provider.provider_code.downcase}" }

    it { should have_http_status(:success) }

    it "has a data section with the correct attributes" do
      perform_request

      expect(json_response).to eq(expected_response)
    end
  end

  context "with two recruitment cycles" do
    let(:next_recruitment_cycle) { create :recruitment_cycle, :next }
    let(:next_provider) {
      create :provider,
             organisations: [organisation],
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
        "/api/v3/recruitment_cycles/#{next_recruitment_cycle.year}" \
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
