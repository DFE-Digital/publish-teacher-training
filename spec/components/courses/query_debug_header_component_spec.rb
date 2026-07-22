# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::QueryDebugHeaderComponent, type: :component do
  subject(:query_debug_header_component_content) do
    render_inline(component).text.gsub(/\r?\n/, " ").squeeze(" ").strip
  end

  let(:component) do
    described_class.new(
      results:,
      applied_filters:,
      debug:,
      environment_name:,
      latitude:,
      longitude:,
    )
  end
  let(:results) { [build(:course)] }
  let(:applied_filters) { {} }
  let(:latitude) { nil }
  let(:longitude) { nil }

  context "when QA" do
    let(:environment_name) { "qa" }

    context "when debug is present" do
      let(:debug) { true }

      it "renders the component" do
        expect(query_debug_header_component_content).not_to be_empty
      end
    end

    context "when debug is not present" do
      let(:debug) { false }

      it "does not render the component" do
        expect(query_debug_header_component_content).to be_empty
      end
    end
  end

  context "when development" do
    let(:environment_name) { "development" }

    context "when debug is present" do
      let(:debug) { true }

      it "renders the component" do
        expect(query_debug_header_component_content).not_to be_empty
      end
    end

    context "when debug is not present" do
      let(:debug) { false }

      it "does not render the component" do
        expect(query_debug_header_component_content).to be_empty
      end
    end
  end

  context "when production" do
    let(:environment_name) { "production" }
    let(:debug) { true }

    it "does not render the component" do
      expect(query_debug_header_component_content).to be_empty
    end
  end

  context "display filter information" do
    let(:debug) { true }
    let(:environment_name) { "qa" }
    let(:applied_filters) { { can_sponsor_visa: true } }

    it "renders applied filters" do
      expect(query_debug_header_component_content).to include("Can sponsor visa: true")
    end
  end

  context "when there is no latitude and longitude" do
    let(:debug) { true }
    let(:environment_name) { "qa" }

    it "does not render location" do
      expect(query_debug_header_component_content).not_to include("latitude")
      expect(query_debug_header_component_content).not_to include("longitude")
    end
  end

  context "when search by location" do
    let(:debug) { true }
    let(:environment_name) { "qa" }

    it "does not render location details" do
      expect(query_debug_header_component_content).not_to include("latitude")
      expect(query_debug_header_component_content).not_to include("longitude")
    end
  end

  context "when rendering nearest school links" do
    let(:debug) { true }
    let(:environment_name) { "qa" }
    let(:latitude) { 51.5 }
    let(:longitude) { -0.1 }
    let(:results) { [course] }
    let(:course) { create(:course, provider:) }
    let(:site) do
      create(
        :site,
        provider:,
        urn: gias_school.urn,
        code: site_code,
        location_name: gias_school.name,
        latitude:,
        longitude:,
      )
    end
    let(:site_code) { "A" }
    let(:gias_school) { create(:gias_school, name: "Debug School") }

    before do
      create(:site_status, :findable, course:, site:)
    end

    context "in the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: 2026) }
      let(:provider) { create(:provider, recruitment_cycle:) }

      it "links to the school using the legacy site uuid" do
        render_inline(component)

        expect(page.find_link("Debug School", visible: :all)[:href]).to include("/schools/#{site.uuid}")
      end
    end

    context "after the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: 2027) }
      let(:provider) { create(:provider, recruitment_cycle:) }

      it "links to the school using the provider school uuid" do
        provider_school = create(:provider_school, provider:, gias_school:, site_code:)
        render_inline(component)

        expect(page.find_link("Debug School", visible: :all)[:href]).to include("/schools/#{provider_school.uuid}")
      end

      it "renders the school name without a school link when the provider school uuid is missing" do
        render_inline(component)

        expect(page).to have_content("Debug School")
        expect(page).not_to have_link("Debug School", visible: :all)
      end
    end
  end
end
