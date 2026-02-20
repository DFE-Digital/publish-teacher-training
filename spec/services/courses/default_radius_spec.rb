require "rails_helper"

RSpec.describe Courses::DefaultRadius do
  describe "#call" do
    it "returns default when no location" do
      radius = described_class.new(
        location: nil,
        formatted_address: nil,
        address_types: nil,
      ).call

      expect(radius).to be 50
    end

    it "returns london radius when formatted_address is london UK" do
      radius = described_class.new(
        location: "London, UK",
        formatted_address: "London, UK",
        address_types: nil,
      ).call

      expect(radius).to eq(20)
    end

    it "returns london radius when formatted_address is london" do
      radius = described_class.new(
        location: "London, UK",
        formatted_address: "London",
        address_types: nil,
      ).call

      expect(radius).to eq(20)
    end

    it "returns small radius when location is postal code" do
      radius = described_class.new(
        location: "SW1A 1AA",
        formatted_address: "Some location",
        address_types: %w[postal_code],
      ).call

      expect(radius).to eq(10)
    end

    it "returns default radius for general locations" do
      radius = described_class.new(
        location: "Bristol",
        formatted_address: "Bristol, UK",
        address_types: nil,
      ).call

      expect(radius).to eq(50)
    end

    it "returns default radius for street address" do
      radius = described_class.new(
        location: "Main St",
        formatted_address: "Main Street, Bristol, UK",
        address_types: %w[route],
      ).call

      expect(radius).to eq(10)
    end
  end

  describe "#location_category" do
    it "returns nil when no location" do
      category = described_class.new(
        location: nil,
        formatted_address: nil,
        address_types: nil,
      ).location_category

      expect(category).to be_nil
    end

    it "returns 'london' for London location" do
      category = described_class.new(
        location: "London, UK",
        formatted_address: "London, UK",
        address_types: %w[locality political],
      ).location_category

      expect(category).to eq("london")
    end

    it "returns 'locality' for postal code location" do
      category = described_class.new(
        location: "SW1A 1AA",
        formatted_address: "Westminster, London SW1A 1AA, UK",
        address_types: %w[postal_code],
      ).location_category

      expect(category).to eq("locality")
    end

    it "returns 'regional' for general locations like Cornwall" do
      category = described_class.new(
        location: "Cornwall, UK",
        formatted_address: "Cornwall, UK",
        address_types: %w[administrative_area_level_2 political],
      ).location_category

      expect(category).to eq("regional")
    end
  end
end
