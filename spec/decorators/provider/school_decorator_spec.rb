# frozen_string_literal: true

require "rails_helper"

describe Provider::SchoolDecorator do
  subject(:decorated) { provider_school.decorate }

  let(:gias_school) do
    create(
      :gias_school,
      name: "St John's School",
      urn: "123456",
      address1: "1 King's Road",
      address2: nil,
      address3: nil,
      town: "Enfield",
      county: "Middlesex",
      postcode: "EN2 7RE",
    )
  end
  let(:provider_school) { create(:provider_school, gias_school:, site_code: "A") }

  describe "#full_address" do
    it "joins the populated address parts" do
      expect(decorated.full_address).to eq("1 King’s Road, Enfield, Middlesex, EN2 7RE")
    end

    # Matches SiteDecorator#full_address so both models render identically
    # while the pickers can still show either.
    it "applies smart quotes" do
      expect(decorated.full_address).to include("King’s")
    end

    it "accepts a separator" do
      expect(decorated.full_address("\n")).to eq("1 King’s Road\nEnfield\nMiddlesex\nEN2 7RE")
    end
  end

  describe "#full_address_on_seperate_lines" do
    it "joins on newlines" do
      expect(decorated.full_address_on_seperate_lines).to eq(decorated.full_address("\n"))
    end
  end

  describe "#location_name" do
    it "applies smart quotes" do
      expect(decorated.location_name).to eq("St John’s School")
    end

    context "when the school is a main site" do
      let(:provider_school) do
        create(:provider_school, gias_school:, site_code: Provider::School::MAIN_SITE_CODE)
      end

      it "includes the main site suffix" do
        expect(decorated.location_name).to eq("St John’s School (Main Site)")
      end
    end
  end

  describe "delegated attributes" do
    it "exposes the site code" do
      expect(decorated.code).to eq("A")
    end

    it "exposes the URN" do
      expect(decorated.urn).to eq("123456")
    end
  end
end
