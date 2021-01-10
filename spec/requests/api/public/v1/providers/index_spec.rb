require "rails_helper"

describe "GET public/v1/recruitment_cycle/:recruitment_cycle_year/providers" do
  let(:organisation) { create(:organisation) }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }

  let(:provider) {
    create(:provider,
           provider_code: "1AT",
           provider_name: "First provider",
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

  context "Searching for a provider" do
    let(:base_provider_path) { "/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers" }
    let(:provider_two) do
      create(:provider,
             provider_code: "2AT",
             provider_name: "Second provider",
             organisations: [organisation],
             contacts: [contact])
    end

    before do
      provider
      provider_two
    end

    context "Searching for a provider by its full name" do
      let(:request_path) { "#{base_provider_path}?search=Second provider" }

      it "Only returns data for the provider" do
        perform_request

        expect(json_response["data"].count).to eq(1)
        expect(json_response["data"].first).to have_attribute("code").with_value("2AT")
      end
    end

    context "Searching for a provider by its lower case full name" do
      let(:request_path) { "#{base_provider_path}?search=second provider" }

      it "Only returns data for the provider" do
        perform_request

        expect(json_response["data"].count).to eq(1)
        expect(json_response["data"].first).to have_attribute("code").with_value("2AT")
      end
    end

    context "Searching for a provider by part of its name" do
      let(:request_path) { "#{base_provider_path}?search=provider" }

      it "Returns data for the matching providers" do
        perform_request

        expect(json_response["data"].count).to eq(2)
        expect(json_response["data"].first).to have_attribute("code").with_value("1AT")
        expect(json_response["data"].last).to have_attribute("code").with_value("2AT")
      end
    end

    context "Searching for a provider by its provider code" do
      let(:request_path) { "#{base_provider_path}?search=2AT" }

      it "Only returns data for the provider" do
        perform_request

        expect(json_response["data"].count).to eq(1)
        expect(json_response["data"].first).to have_attribute("code").with_value("2AT")
      end
    end

    context "Searching for a provider by a lower case provider code" do
      let(:request_path) { "#{base_provider_path}?search=2at" }

      it "Only returns data for the provider" do
        perform_request

        expect(json_response["data"].count).to eq(1)
        expect(json_response["data"].first).to have_attribute("code").with_value("2AT")
      end
    end

    context "Searching for a provider with an invalid query" do
      context "query is empty" do
        let(:request_path) { "#{base_provider_path}?search=" }

        it "returns all providers" do
          perform_request

          expect(json_response["data"].count).to eq(2)
        end
      end

      context "query is less than 2 characters" do
        let(:request_path) { "#{base_provider_path}?search=a" }

        it "returns Bad Request" do
          perform_request

          expect(response.status).to eq(400)
        end
      end
    end
  end
end
