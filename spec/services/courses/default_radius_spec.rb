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
      allow(FeatureFlag).to receive(:active?).with(:find_filtering_and_sorting).and_return(true)

      radius = described_class.new(
        location: "London, UK",
        formatted_address: "London, UK",
        address_types: nil,
      ).call

      expect(radius).to eq(20)
    end

    it "returns london radius when formatted_address is london" do
      allow(FeatureFlag).to receive(:active?).with(:find_filtering_and_sorting).and_return(true)

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
end
