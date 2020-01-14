require "rails_helper"

describe "GET v3/recruitment_cycle/:recruitment_cycle_year/providers" do
  let(:organisation) { create(:organisation) }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }

  let!(:provider) {
    create(:provider,
           organisations: [organisation],
           contacts: [contact])
  }
  let(:contact) { build(:contact) }

  let(:json_response) { JSON.parse(response.body) }

  def perform_request
    get request_path
  end

  subject do
    perform_request

    response
  end

  describe "JSON generated for a providers" do
    let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers" }

    it { should have_http_status(:success) }

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
    let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers" }

    before do
      second_alphabetical_provider

      # This moves it last in the order that it gets fetched by default.
      provider.update(provider_name: "Acme")
    end

    let(:provider_names_in_response) {
      JSON.parse(subject.body)["data"].map { |provider|
        provider["attributes"]["provider_name"]
      }
    }

    it "returns them in alphabetical order" do
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
      let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers" }

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
        "/api/v3/recruitment_cycles/#{next_recruitment_cycle.year}/providers"
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
