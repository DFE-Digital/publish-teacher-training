require "rails_helper"

describe "GET public/v1/recruitment_cycle/:recruitment_cycle_year/providers" do
  let(:organisation) { create(:organisation) }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }

  let!(:provider) {
    create(:provider,
           provider_code: "1AT",
           provider_name: "First provider",
           organisations: [organisation],
           contacts: [contact])
  }

  let(:contact) { build(:contact) }

  let(:json_response) { JSON.parse(response.body) }
  let(:data) { json_response["data"] }

  def perform_request
    get request_path
  end

  subject do
    perform_request

    response
  end

  let(:request_path) { "/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers" }

  describe "JSON generated for a providers" do
    it { should have_http_status(:success) }

    it "has a data section with the correct attributes" do
      perform_request

      expect(json_response).to eq(
        "data" => [{
          "id" => provider.id.to_s,
          "type" => "providers",
          "attributes" => {
            "code" => provider.provider_code,
            "name" => provider.provider_name,
            "recruitment_cycle_year" => provider.recruitment_cycle.year,
            "postcode" => provider.postcode,
            "provider_type" => provider.provider_type,
            "region_code" => provider.region_code,
            "train_with_disability" => provider.train_with_disability,
            "train_with_us" => provider.train_with_us,
            "website" => provider.website,
            "accredited_body" => provider.accredited_body?,
            "changed_at" => provider.changed_at.iso8601,
            "city" => provider.address3,
            "county" => provider.address4,
            "created_at" => provider.created_at.iso8601,
            "street_address_1" => provider.address1,
            "street_address_2" => provider.address2,
          },
        }],
        "jsonapi" => {
          "version" => "1.0",
        },
      )
    end
  end

  context "with unalphabetical ordering in the database" do
    let(:second_alphabetical_provider) do
      create(:provider, provider_name: "Zork", organisations: [organisation])
    end

    before do
      second_alphabetical_provider

      # This moves it last in the order that it gets fetched by default.
      provider.update(provider_name: "Acme")
    end

    let(:provider_names_in_response) {
      data.map { |provider|
        provider["attributes"]["name"]
      }
    }

    it "returns them in alphabetical order" do
      perform_request
      expect(provider_names_in_response).to eq(%w(Acme Zork))
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

        expect(data.count).to eq 1
        expect(data.first)
          .to have_attribute("recruitment_cycle_year")
                .with_value(recruitment_cycle.year)
      end
    end

    describe "making a request for the next recruitment cycle" do
      let(:request_path) {
        "/api/public/v1/recruitment_cycles/#{next_recruitment_cycle.year}/providers"
      }

      it "only returns data for the next recruitment cycle" do
        next_provider

        perform_request

        expect(data.count).to eq 1
        expect(data.first)
          .to have_attribute("recruitment_cycle_year")
                .with_value(next_recruitment_cycle.year)
      end
    end
  end

  context "Sparse fields" do
    before { perform_request }

    context "Only returning specified fields" do
      let(:request_path) { "/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers?fields[providers]=name,recruitment_cycle_year" }

      it "Only returns the specified field" do
        expect(data.first["attributes"].keys.count).to eq(2)
        expect(data.first).to have_attribute("name")
        expect(data.first).to have_attribute("recruitment_cycle_year")
      end
    end

    context "Default fields" do
      fields = %w[ postcode
                   provider_type
                   region_code
                   train_with_disability
                   train_with_us
                   website
                   accredited_body
                   changed_at
                   city
                   code
                   county
                   created_at
                   name
                   recruitment_cycle_year
                   street_address_1
                   street_address_2]

      it "Returns the Default fields" do
        expect(data.first["attributes"].keys).to match_array(fields)
      end
    end
  end
end
