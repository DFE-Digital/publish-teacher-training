# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::SearchLocation do
  describe "#located?" do
    it "is true when both coordinates are present" do
      location = described_class.new(latitude: "51.5074", longitude: "-0.1278")
      expect(location.located?).to be true
    end

    it "is false when latitude is missing" do
      location = described_class.new(longitude: "-0.1278")
      expect(location.located?).to be false
    end

    it "is false when longitude is missing" do
      location = described_class.new(latitude: "51.5074")
      expect(location.located?).to be false
    end

    it "is false when both coordinates are missing" do
      location = described_class.new(text: "London")
      expect(location.located?).to be false
    end

    it "is false when coordinates are empty strings" do
      location = described_class.new(latitude: "", longitude: "")
      expect(location.located?).to be false
    end

    it "treats display fields (text, short_address, formatted_address) as irrelevant" do
      location = described_class.new(
        text: "Atlantis",
        short_address: "Atlantis",
        formatted_address: "Atlantis, Ocean",
      )
      expect(location.located?).to be false
    end
  end

  describe "#blank?" do
    it "is true when every field is blank" do
      expect(described_class.new.blank?).to be true
    end

    it "is true when only empty strings are passed" do
      location = described_class.new(text: "", formatted_address: "", short_address: "")
      expect(location.blank?).to be true
    end

    it "is false when text is present" do
      expect(described_class.new(text: "London").blank?).to be false
    end

    it "is false when formatted_address is present" do
      expect(described_class.new(formatted_address: "London, UK").blank?).to be false
    end

    it "is false when short_address is present" do
      expect(described_class.new(short_address: "London").blank?).to be false
    end

    it "is false when coordinates are present" do
      location = described_class.new(latitude: "51.5074", longitude: "-0.1278")
      expect(location.blank?).to be false
    end
  end

  describe "#label" do
    it "prefers short_address" do
      location = described_class.new(
        text: "London NW9, UK",
        short_address: "London NW9",
        formatted_address: "London NW9, United Kingdom",
      )
      expect(location.label).to eq("London NW9")
    end

    it "falls back to formatted_address when short_address is blank" do
      location = described_class.new(
        text: "London NW9, UK",
        formatted_address: "London NW9, United Kingdom",
      )
      expect(location.label).to eq("London NW9, United Kingdom")
    end

    it "falls back to text when both short_address and formatted_address are blank" do
      location = described_class.new(text: "London NW9, UK")
      expect(location.label).to eq("London NW9, UK")
    end

    it "is nil when every label-candidate is blank" do
      expect(described_class.new.label).to be_nil
    end
  end

  describe ".from_params" do
    it "extracts every field from a string-keyed hash" do
      location = described_class.from_params(
        "location" => "London, UK",
        "latitude" => "51.5074",
        "longitude" => "-0.1278",
        "formatted_address" => "London, United Kingdom",
        "short_address" => "London",
      )

      expect(location.located?).to be true
      expect(location.label).to eq("London")
    end

    it "extracts every field from a symbol-keyed hash" do
      location = described_class.from_params(
        location: "London, UK",
        latitude: "51.5074",
        longitude: "-0.1278",
        formatted_address: "London, United Kingdom",
        short_address: "London",
      )

      expect(location.located?).to be true
      expect(location.label).to eq("London")
    end

    it "returns a blank location for an empty hash" do
      expect(described_class.from_params({}).blank?).to be true
    end
  end
end
