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
end
