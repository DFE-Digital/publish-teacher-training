# frozen_string_literal: true

require "rails_helper"

RSpec.describe Provider::SchoolDecorator do
  subject(:decorated_school) { provider_school.decorate }

  let(:gias_school) do
    create(
      :gias_school,
      name: "Example School",
      urn: "123456",
      address1: "1 Example Road",
      town: "Example Town",
      postcode: "EX1 1AA",
    )
  end
  let(:provider_school) { create(:provider_school, gias_school:, site_code:) }
  let(:site_code) { "A" }

  describe "#location_name" do
    context "when the school is a main site" do
      let(:site_code) { Provider::School::MAIN_SITE_CODE }

      it "includes the main site suffix" do
        expect(decorated_school.location_name).to eq("Example School (Main Site)")
      end
    end

    context "when the school is not a main site" do
      it "returns the GIAS school name" do
        expect(decorated_school.location_name).to eq("Example School")
      end
    end
  end

  describe "#full_address_on_seperate_lines" do
    it "returns the GIAS address on separate lines" do
      expect(decorated_school.full_address_on_seperate_lines).to eq("1 Example Road\nExample Town\nEX1 1AA")
    end
  end
end
