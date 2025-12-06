# frozen_string_literal: true

require "rails_helper"

RSpec.describe Geolocation::Address do
  describe "#short_address" do
    context "when full postcode" do
      let(:address) do
        described_class.new(
          query: "SW1H 9AJ",
          formatted_address: "Westminster, London",
          latitude: 51.5,
          longitude: -0.1,
          postal_code: "SW1H 9AJ",
          postal_town: "London",
          route: "Petty France",
        )
      end

      it "returns postal code" do
        expect(address.short_address).to eq("SW1H 9AJ")
      end
    end

    context "when city/locality only" do
      let(:address) do
        described_class.new(
          query: "Manchester",
          formatted_address: "Manchester, UK",
          latitude: 53.4,
          longitude: -2.2,
          postal_code: nil,
          postal_town: nil,
          route: nil,
          locality: "Manchester",
          administrative_area_level_1: "England",
        )
      end

      it "returns city name" do
        expect(address.short_address).to eq("Manchester")
      end
    end

    context "when partial postcode" do
      let(:address) do
        described_class.new(
          query: "Cambridge CB2",
          formatted_address: "Cambridge, UK",
          latitude: 52.2,
          longitude: 0.1,
          postal_code: "CB2",
          postal_town: "Cambridge",
        )
      end

      it "returns postcode and town" do
        expect(address.short_address).to eq("CB2, Cambridge")
      end
    end

    context "when landmark/location" do
      let(:address) do
        described_class.new(
          query: "Borough Market, London",
          formatted_address: "Borough Market, London, UK",
          latitude: 51.5,
          longitude: -0.1,
          postal_code: "SE1 1TL",
          postal_town: "London",
          route: "Borough Market",
        )
      end

      it "returns route and town" do
        expect(address.short_address).to eq("Borough Market, London")
      end
    end

    context "when postcode area" do
      let(:address) do
        described_class.new(
          query: "M1",
          formatted_address: "Manchester M1, UK",
          latitude: 53.4,
          longitude: -2.2,
          postal_code: "M1",
          postal_town: "Manchester",
        )
      end

      it "returns postcode area and town" do
        expect(address.short_address).to eq("M1, Manchester")
      end
    end

    context "when district/neighborhood only" do
      let(:address) do
        described_class.new(
          query: "Shoreditch, London",
          formatted_address: "Shoreditch, London, UK",
          latitude: 51.5,
          longitude: -0.1,
          postal_code: nil,
          postal_town: "London",
          route: nil,
          administrative_area_level_4: "Shoreditch",
        )
      end

      it "returns district and town" do
        expect(address.short_address).to eq("Shoreditch, London")
      end
    end

    context "when train station" do
      let(:address) do
        described_class.new(
          query: "King's Cross Station",
          formatted_address: "King's Cross St Pancras, London, UK",
          latitude: 51.5,
          longitude: -0.1,
          postal_code: "WC1H 7PL",
          postal_town: "London",
          route: "King's Cross St Pancras",
        )
      end

      it "returns station name" do
        expect(address.short_address).to eq("King's Cross St Pancras")
      end
    end

    context "when university" do
      let(:address) do
        described_class.new(
          query: "University of Cambridge",
          formatted_address: "University of Cambridge, UK",
          latitude: 52.2,
          longitude: 0.1,
          postal_code: "CB2 1TN",
          postal_town: "Cambridge",
          route: "University of Cambridge",
        )
      end

      it "returns university name" do
        expect(address.short_address).to eq("University of Cambridge")
      end
    end

    context "when county/region" do
      let(:address) do
        described_class.new(
          query: "Devon",
          formatted_address: "Devon, UK",
          latitude: 50.7,
          longitude: -3.5,
          postal_code: nil,
          postal_town: nil,
          route: nil,
          locality: nil,
          administrative_area_level_1: "Devon",
        )
      end

      it "returns county/region name" do
        expect(address.short_address).to eq("Devon")
      end
    end

    context "when street name" do
      let(:address) do
        described_class.new(
          query: "Oxford Street, London",
          formatted_address: "Oxford Street, London, UK",
          latitude: 51.5,
          longitude: -0.1,
          postal_code: nil,
          postal_town: "London",
          route: "Oxford Street",
        )
      end

      it "returns street name and town" do
        expect(address.short_address).to eq("Oxford Street, London")
      end
    end

    context "when fallback to formatted address" do
      let(:address) do
        described_class.new(
          query: "Some Place",
          formatted_address: "Some Place, UK",
          latitude: 51.5,
          longitude: -0.1,
        )
      end

      it "returns formatted address" do
        expect(address.short_address).to eq("Some Place")
      end
    end
  end
end
