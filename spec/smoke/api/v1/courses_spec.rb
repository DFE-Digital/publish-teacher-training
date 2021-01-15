# frozen_string_literal: true

require "spec_helper_smoke"

describe "V1 Public API Smoke Tests", :aggregate_failures, smoke: true do
  let(:base_url) { Settings.publish_url.sub("www", "api") }

  subject(:response) { HTTParty.get(url) }

  context "courses" do
    describe "GET /api/public/v1/recruitment_cycles/:recruitment_year/courses" do
      let(:recruitment_year) { Settings.current_recruitment_cycle_year }
      let(:url) { "#{base_url}/api/public/v1/recruitment_cycles/#{recruitment_year}/courses?page[per_page]=1" }

      it "returns HTTP success" do
        expect(response.code).to eq(200)
      end

      it "returns at least one record" do
        expect(response.parsed_response["data"].length).to be_positive
      end

      it "returns at positive record count within meta" do
        expect(response.parsed_response["meta"]["count"]).to be_positive
      end
    end
  end
end
