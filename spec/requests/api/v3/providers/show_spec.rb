# frozen_string_literal: true

require "rails_helper"

describe "GET v3/recruitment_cycle/:recruitment_cycle_year/providers/:provider_code", :with_publish_constraint do
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers/#{provider.provider_code}" }
  let(:request_params) { {} }

  let(:user) { create(:user) }
  let(:payload) { { email: user.email } }

  let(:site) { build(:site) }
  let(:description) { "An accredited body description" }
  let(:accrediting_provider_enrichments) do
    [{
      "UcasProviderCode" => accrediting_provider.provider_code,
      "Description" => description,
    }]
  end
  let(:accrediting_provider) { create(:provider) }
  let(:course) { create(:course, accrediting_provider:) }
  let(:courses) { [course] }
  let!(:provider) do
    create(:provider,
      sites: [site],
      users: [user],
      accrediting_provider_enrichments:,
      courses:,
      contacts: [contact],
      ucas_preferences:)
  end
  let(:contact) { build(:contact) }
  let(:ucas_preferences) { build(:provider_ucas_preference) }

  let(:expected_response) do
    {
      "data" => {
        "id" => provider.id.to_s,
        "type" => "providers",
        "attributes" => {
          "provider_code" => provider.provider_code,
          "provider_name" => provider.provider_name,
          "address1" => provider.address1,
          "address2" => provider.address2,
          "address3" => provider.address3,
          "address4" => provider.address4,
          "postcode" => provider.postcode,
          "telephone" => provider.telephone,
          "email" => provider.email,
          "website" => provider.website,
          "train_with_us" => provider.train_with_us,
          "train_with_disability" => provider.train_with_disability,
          "can_sponsor_student_visa" => provider.can_sponsor_student_visa,
          "can_sponsor_skilled_worker_visa" => provider.can_sponsor_skilled_worker_visa,
          "recruitment_cycle_year" => provider.recruitment_cycle.year,
        },
      },
      "jsonapi" => {
        "version" => "1.0",
      },
    }
  end

  let(:json_response) { JSON.parse(response.body) }

  subject do
    perform_request
    response
  end

  def perform_request
    get request_path, params: request_params
  end

  context "including courses.subjects" do
    let(:request_params) { { include: "courses.subjects" } }

    it { is_expected.to have_http_status(:success) }
  end

  context "including sites" do
    let(:request_params) { { include: "sites" } }

    it { is_expected.to have_http_status(:success) }

    it "has a data section with the correct attributes" do
      perform_request

      expect(json_response).to eq(expected_response)
    end
  end

  describe "JSON generated for a provider" do
    it { is_expected.to have_http_status(:success) }

    it "has a data section with the correct attributes" do
      perform_request

      expect(json_response).to eq(expected_response)
    end
  end

  describe "with lowercase provider code" do
    let(:request_path) { "/api/v3/recruitment_cycles/#{recruitment_cycle.year}/providers/#{provider.provider_code.downcase}" }

    it { is_expected.to have_http_status(:success) }

    it "has a data section with the correct attributes" do
      perform_request

      expect(json_response).to eq(expected_response)
    end
  end

  context "with two recruitment cycles" do
    let(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }
    let(:next_provider) do
      create(:provider,
        users: [user],
        provider_code: provider.provider_code,
        recruitment_cycle: next_recruitment_cycle)
    end

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
      let(:request_path) do
        "/api/v3/recruitment_cycles/#{next_recruitment_cycle.year}" \
          "/providers/#{next_provider.provider_code}"
      end

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
