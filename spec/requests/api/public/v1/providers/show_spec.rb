require "rails_helper"

describe "GET public/v1/recruitment_cycle/:recruitment_cycle_year/providers/:provider_code" do
  let(:recruitment_cycle_year) { provider.recruitment_cycle.year }
  let(:provider_code) { provider.provider_code }

  let(:request_path) do
    "/api/public/v1/recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}"
  end

  let!(:provider) { create(:provider) }

  let(:data) do
    {
      "id" => provider.id.to_s,
      "type" => "providers",
      "attributes" => {
        "code" => provider.provider_code,
        "name" => provider.provider_name,
        "recruitment_cycle_year" => provider.recruitment_cycle.year.to_i,
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
    }
  end

  let(:expected_response) do
    {
      "data" => data,
      "jsonapi" => {
        "version" => "1.0",
      },
    }
  end

  let(:json_response) { JSON.parse(subject.body) }

  subject do
    perform_request
    response
  end

  def perform_request
    get request_path
  end

  describe "JSON generated for a provider" do
    it { should have_http_status(:success) }

    it "has a data section with the correct attributes" do
      expect(json_response).to eq(expected_response)
    end
  end

  describe "with unknown provider code" do
    let(:provider_code) { "unknown" }

    let(:data) { nil }
    it { should have_http_status(:not_found) }

    it "has a data section with the correct attributes" do
      expect(json_response).to eq(expected_response)
    end
  end

  describe "with lowercase provider code" do
    let(:provider_code) { provider.provider_code.downcase }

    it { should have_http_status(:success) }

    it "has a data section with the correct attributes" do
      expect(json_response).to eq(expected_response)
    end
  end

  context "with two recruitment cycles" do
    let(:next_recruitment_cycle) { create :recruitment_cycle, :next }
    let!(:next_provider) do
      create(:provider, recruitment_cycle: next_recruitment_cycle)
    end

    describe "making a request for the current recruitment cycle" do
      it "only returns data for the current recruitment cycle" do
        expect(json_response["data"])
          .to have_attribute("recruitment_cycle_year")
                .with_value(provider.recruitment_cycle.year.to_i)
        expect(json_response["data"])
          .to have_attribute("code")
                .with_value(provider.provider_code)
      end
    end

    describe "making a request for the next recruitment cycle" do
      let(:recruitment_cycle_year) { next_provider.recruitment_cycle.year }
      let(:provider_code) { next_provider.provider_code }

      it "only returns data for the next recruitment cycle" do
        expect(json_response["data"])
          .to have_attribute("recruitment_cycle_year")
                .with_value(next_recruitment_cycle.year.to_i)
        expect(json_response["data"])
          .to have_attribute("code")
                .with_value(next_provider.provider_code)
      end
    end
  end
end
