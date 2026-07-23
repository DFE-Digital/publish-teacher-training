# frozen_string_literal: true

require "rails_helper"

describe Provider::SchoolDecorator do
  subject(:decorated) { provider_school.decorate }

  let(:gias_school) { build(:gias_school, name: "Springfield Primary") }
  let(:provider_school) { build(:provider_school, gias_school:, site_code:) }

  context "when the school is a main site" do
    let(:site_code) { Provider::School::MAIN_SITE_CODE }

    it "appends the main site suffix to the location name" do
      expect(decorated.location_name).to eq("Springfield Primary (Main Site)")
    end
  end

  context "when the school is not a main site" do
    let(:site_code) { "AB" }

    it "returns the GIAS school name without a suffix" do
      expect(decorated.location_name).to eq("Springfield Primary")
    end
  end

  describe "#full_address_on_seperate_lines" do
    let(:site_code) { "AB" }
    let(:gias_school) do
      build(
        :gias_school,
        address1: "1 High Street",
        address2: "Town Centre",
        town: "London",
        county: "Greater London",
        postcode: "SW1A 1AA",
      )
    end

    it "formats the GIAS address on separate lines" do
      expect(decorated.full_address_on_seperate_lines).to eq(
        "1 High Street\nTown Centre\nLondon\nGreater London\nSW1A 1AA",
      )
    end
  end
end
