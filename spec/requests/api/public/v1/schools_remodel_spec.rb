# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools remodel cycle selection", service: :api do
  # Keep these years explicit so changing the setting cannot silently stop
  # covering the 2026 cycle. Both models contain different schools to prove
  # which records the API actually serves.
  [2025, 2026, 2027].each do |year|
    context "in the #{year} recruitment cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year:) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let(:course) { create(:course, provider:) }
      let(:legacy_site) { create(:site, provider:, location_name: "Legacy school") }
      let(:gias_school) { create(:gias_school, name: "Remodelled school") }
      let(:base_path) { "/api/public/v1/recruitment_cycles/#{year}/providers/#{provider.provider_code}" }

      before do
        course.sites << legacy_site
        create(:course_school, course:, gias_school:)
      end

      it "serves #{year == 2025 ? 'legacy sites' : 'provider schools'} as provider locations" do
        get "#{base_path}/locations"

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].map { |location| location.dig("attributes", "name") })
          .to eq([year == 2025 ? "Legacy school" : "Remodelled school"])
      end

      it "serves #{year == 2025 ? 'legacy sites' : 'course schools'} as course locations" do
        get "#{base_path}/courses/#{course.course_code}/locations"

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].map { |location| location.dig("attributes", "name") })
          .to eq([year == 2025 ? "Legacy school" : "Remodelled school"])
      end
    end
  end
end
