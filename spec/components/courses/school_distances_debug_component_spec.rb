# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::SchoolDistancesDebugComponent do
  subject(:school_distances_debug_component_content) do
    rendered_component.text.gsub(/\r?\n/, " ").squeeze(" ").strip
  end

  let(:rendered_component) do
    render_inline(component)
  end

  let(:component) do
    described_class.new(
      course:,
      latitude:,
      longitude:,
      debug:,
      environment_name:,
    )
  end

  let(:course) { create(:course, name: "Maths (M123)", provider:) }
  let(:provider) { create(:provider, provider_name: "Test Provider", provider_code: "TP123") }
  let(:latitude) { 51.5074 }
  let(:longitude) { -0.1278 }

  context "when QA" do
    let(:environment_name) { "qa" }

    context "when debug is present and location is provided" do
      let(:debug) { true }

      it "renders the component" do
        expect(school_distances_debug_component_content).to include("School distances for Test Provider (TP123) - Maths (M123)")
      end
    end

    context "when debug is not present" do
      let(:debug) { false }

      it "does not render the component" do
        expect(school_distances_debug_component_content).to be_empty
      end
    end
  end

  context "when development" do
    let(:environment_name) { "development" }

    context "when debug is present and location is provided" do
      let(:debug) { true }

      it "renders the component" do
        expect(school_distances_debug_component_content).to include("School distances for Test Provider (TP123) - Maths (M123)")
      end
    end

    context "when debug is not present" do
      let(:debug) { false }

      it "does not render the component" do
        expect(school_distances_debug_component_content).to be_empty
      end
    end
  end

  context "when review" do
    let(:environment_name) { "review" }

    context "when debug is present and location is provided" do
      let(:debug) { true }

      it "renders the component" do
        expect(school_distances_debug_component_content).to include("School distances for Test Provider (TP123) - Maths (M123)")
      end
    end

    context "when debug is not present" do
      let(:debug) { false }

      it "does not render the component" do
        expect(school_distances_debug_component_content).to be_empty
      end
    end
  end

  context "when production" do
    let(:environment_name) { "production" }
    let(:debug) { true }

    it "does not render the component" do
      expect(school_distances_debug_component_content).to be_empty
    end
  end

  context "when latitude and longitude are missing" do
    let(:environment_name) { "qa" }
    let(:debug) { true }
    let(:latitude) { nil }
    let(:longitude) { nil }

    it "does not render the component" do
      expect(school_distances_debug_component_content).to be_empty
    end
  end

  context "when render the school distances" do
    let(:environment_name) { "qa" }
    let(:debug) { true }
    let(:manchester) { build(:location, :manchester) }
    let(:bristol) { build(:location, :bristol) }

    it "renders the details summary with the course provider and name" do
      schools = [
        create(:site_status, site: build(:site, latitude: manchester.latitude, longitude: manchester.longitude), course:),
        create(:site_status, site: build(:site, latitude: bristol.latitude, longitude: bristol.longitude), course:),
      ]

      expect(school_distances_debug_component_content).to include("School distances for Test Provider (TP123) - Maths (M123)")

      schools.each do |school|
        expect(school_distances_debug_component_content).to have_text(school.site.location_name)
        expect(school_distances_debug_component_content).to have_text(school.site.latitude.to_s)
        expect(school_distances_debug_component_content).to have_text(school.site.longitude.to_s)
        expect(rendered_component.css("a").map { |a| a[:href] }).to include(
          "https://www.google.com/maps/dir/#{latitude},#{longitude}/#{school.site.latitude},#{school.site.longitude}",
        )
      end
    end
  end
end
