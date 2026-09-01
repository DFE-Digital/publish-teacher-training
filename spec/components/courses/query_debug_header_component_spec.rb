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
    let(:recruitment_cycle) { create(:recruitment_cycle, year: 2026) }
    let(:provider) { create(:provider, recruitment_cycle:) }
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

    # The link resolves against Provider::School#uuid in Publish, so that is the
    # only uuid worth rendering - a legacy site uuid would 404 there.
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

    it "labels the column as a school rather than a site" do
      expect(query_debug_header_component_content).to include("Nearest School")
      expect(query_debug_header_component_content).not_to include("Nearest Site")
    end
  end

  context "when the results only have canonical schools" do
    before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }
    after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

    let(:debug) { true }
    let(:environment_name) { "qa" }
    let(:latitude) { 51.5 }
    let(:longitude) { -0.1 }
    let(:results) { [course] }
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider:) }
    let(:gias_school) { create(:gias_school, name: "Canonical School", latitude: 51.5045, longitude: -0.0243) }
    let!(:course_school) { create(:course_school, course:, gias_school:) }

    it "lists the nearest GIAS school with no Site or SiteStatus in play" do
      render_inline(component)

      expect(course.site_statuses).to be_empty
      expect(page).to have_content("Canonical School")
      expect(page.find_link("Canonical School", visible: :all)[:href]).to include(
        "/schools/#{course_school.provider_school.uuid}",
      )
    end

    it "renders the school's coordinates and distance" do
      expect(query_debug_header_component_content).to include("51.5045")
      expect(query_debug_header_component_content).to include("-0.0243")
      expect(query_debug_header_component_content).to include("3.27 miles")
    end
  end
end
