# frozen_string_literal: true

require "rails_helper"

RSpec.describe Geolocation::CoordinatesQuery do
  subject(:coordinates) { coordinates_query.call }

  let(:london) { build(:location, :london) }
  let(:manchester) { build(:location, :manchester) }
  let(:edinburgh) { build(:location, :edinburgh) }
  let(:belfast) { build(:location, :belfast) }
  let(:cardiff) { build(:location, :cardiff) }

  let(:query) { "London" }
  let(:client) { instance_double(GoogleOldPlacesAPI::Client) }
  let(:cache) { Rails.cache }
  let(:cache_expiration) { 30.days }

  let(:coordinates_query) do
    described_class.new(query, cache:, client:, cache_expiration:)
  end

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe "#call" do
    context "when query is blank" do
      let(:query) { "" }

      it "returns blank CoordinatesResult" do
        expect(coordinates).to be_a(Geolocation::CoordinatesResult)
        expect(coordinates.latitude).to be_nil
        expect(coordinates.longitude).to be_nil
        expect(coordinates.country).to be_nil
        expect(coordinates.formatted_address).to be_nil
      end

      it "does not cache" do
        coordinates_query.call

        expect(cache.read(coordinates_query.cache_key)).to be_nil
      end
    end

    context "when results do not return latitude" do
      before do
        allow(client).to receive(:geocode).and_return(formatted_address: "An address", latitude: nil)
      end

      it "returns blank CoordinatesResult" do
        expect(coordinates).to be_a(Geolocation::CoordinatesResult)
        expect(coordinates.latitude).to be_nil
        expect(coordinates.longitude).to be_nil
        expect(coordinates.country).to be_nil
        expect(coordinates.formatted_address).to be_nil
      end

      it "does not cache" do
        coordinates_query.call

        expect(cache.read(coordinates_query.cache_key)).to be_nil
      end
    end

    context "when results do not return longitude" do
      before do
        allow(client).to receive(:geocode).and_return(formatted_address: "An address", longitude: nil)
      end

      it "returns blank CoordinatesResult" do
        expect(coordinates).to be_a(Geolocation::CoordinatesResult)
        expect(coordinates.latitude).to be_nil
        expect(coordinates.longitude).to be_nil
        expect(coordinates.country).to be_nil
        expect(coordinates.formatted_address).to be_nil
      end

      it "does not cache" do
        coordinates_query.call

        expect(cache.read(coordinates_query.cache_key)).to be_nil
      end
    end

    context "when coordinates are cached" do
      let(:cached_hash) do
        {
          formatted_address: "London, UK",
          latitude: london.latitude,
          longitude: london.longitude,
          country: "GB",
          postal_code: "SW1A 1AA",
          postal_town: "London",
          route: "Parliament Street",
          locality: "London",
          administrative_area_level_1: "England",
          administrative_area_level_4: "City of Westminster",
        }
      end

      before do
        cache.write(coordinates_query.cache_key, cached_hash, expires_in: cache_expiration)
      end

      it "returns CoordinatesResult from cached hash" do
        result = coordinates

        expect(result).to be_a(Geolocation::CoordinatesResult)
        expect(result.formatted_address).to eq("London, UK")
        expect(result.latitude).to eq(london.latitude)
        expect(result.longitude).to eq(london.longitude)
        expect(result.country).to eq("GB")
        expect(result.postal_code).to eq("SW1A 1AA")
        expect(result.postal_town).to eq("London")
        expect(result.route).to eq("Parliament Street")
        expect(result.locality).to eq("London")
        expect(result.administrative_area_level_1).to eq("England")
        expect(result.administrative_area_level_4).to eq("City of Westminster")
      end

      it "logs a cache hit" do
        expect(Rails.logger).to receive(:info).with(
          "Cache HIT for: '#{query}' | Key: geolocation:coordinates:v2:london | Cached: #{cached_hash.inspect}",
        )
        coordinates
      end
    end

    context "when coordinates are not cached" do
      let(:query) { "Manchester" }
      let(:common_hash) do
        {
          formatted_address: "Manchester, UK",
          latitude: manchester.latitude,
          longitude: manchester.longitude,
          country: "GB",
          postal_code: "M1 1AA",
          postal_town: "Manchester",
          route: "Market Street",
          locality: "Manchester",
          administrative_area_level_1: "England",
          administrative_area_level_4: "Manchester",
          address_types: %w[
            locality
            political
          ],
        }
      end

      before do
        allow(client).to receive(:geocode).with(query).and_return(common_hash)
      end

      it "fetches and caches the coordinates" do
        expect(cache.read(coordinates_query.cache_key)).to be_nil

        result = coordinates_query.call

        expect(result).to be_a(Geolocation::CoordinatesResult)
        expect(result.latitude).to eq(manchester.latitude)
        expect(result.longitude).to eq(manchester.longitude)

        expect(cache.read(coordinates_query.cache_key)).to eq(common_hash)
      end

      it "logs a cache miss" do
        expect(Rails.logger).to receive(:info).with(
          "Cache MISS for: '#{query}' | Key: geolocation:coordinates:v2:manchester | Caching: #{common_hash.inspect}",
        )
        coordinates
      end
    end

    context "when geocoding search results in an error" do
      before do
        allow(client).to receive(:geocode).with(query).and_return(nil)
      end

      it "returns blank CoordinatesResult" do
        result = coordinates

        expect(result).to be_a(Geolocation::CoordinatesResult)
        expect(result.latitude).to be_nil
        expect(result.longitude).to be_nil
        expect(result.country).to be_nil
        expect(result.formatted_address).to be_nil
      end

      it "captures the error in Sentry" do
        allow(client).to receive(:geocode).and_raise(StandardError, "Geocoding failed")
        allow(Sentry).to receive(:capture_exception)

        coordinates

        expect(Sentry).to have_received(:capture_exception).with(
          instance_of(StandardError),
          hash_including(
            message: "Location search failed for Geolocation::CoordinatesQuery - #{query}, location search ignored (user experience unaffected)",
          ),
        )
      end
    end

    context "when coordinates are fetched from GoogleOldPlacesAPI" do
      let(:common_hash) do
        {
          formatted_address: "London, UK",
          latitude: london.latitude,
          longitude: london.longitude,
          country: "GB",
          postal_code: "SW1A 1AA",
          postal_town: "London",
          route: "Parliament Street",
          locality: "London",
          administrative_area_level_1: "England",
          administrative_area_level_4: "City of Westminster",
          address_types: [],
        }
      end

      before do
        allow(client).to receive(:geocode).with(query).and_return(common_hash)
        allow(Rails.cache).to receive(:write).and_call_original
      end

      it "fetches normalized common hash from GoogleOldPlacesAPI" do
        result = coordinates_query.call

        expect(client).to have_received(:geocode).with(query)
        expect(result).to be_a(Geolocation::CoordinatesResult)
      end

      it "caches the normalized common hash" do
        coordinates_query.call

        expect(Rails.cache.read(coordinates_query.cache_key)).to eq(common_hash)
      end

      it "wraps hash in CoordinatesResult" do
        result = coordinates_query.call

        expect(result.to_h).to eq(common_hash)
      end
    end

    context "when searching for England location" do
      let(:london_hash) do
        {
          formatted_address: "London, UK",
          latitude: london.latitude,
          longitude: london.longitude,
          country: "GB",
          postal_code: "SW1A 1AA",
          postal_town: "London",
          route: "Parliament Street",
          locality: "London",
          administrative_area_level_1: "England",
          administrative_area_level_4: "City of Westminster",
        }
      end

      before do
        allow(client).to receive(:geocode).with(query).and_return(london_hash)
      end

      it "returns CoordinatesResult with correct attributes" do
        result = coordinates_query.call

        expect(result).to be_a(Geolocation::CoordinatesResult)
        expect(result.latitude).to eq(london.latitude)
        expect(result.longitude).to eq(london.longitude)
        expect(result.country).to eq("GB")
        expect(result.administrative_area_level_1).to eq("England")
      end
    end

    context "when searching for Scotland location" do
      let(:query) { "Edinburgh" }
      let(:edinburgh_hash) do
        {
          formatted_address: "Edinburgh, UK",
          latitude: edinburgh.latitude,
          longitude: edinburgh.longitude,
          country: "GB",
          postal_code: "EH8 8PB",
          postal_town: "Edinburgh",
          route: "Royal Mile",
          locality: "Edinburgh",
          administrative_area_level_1: "Scotland",
          administrative_area_level_4: "Edinburgh",
        }
      end

      let(:coordinates_query) do
        described_class.new(query, cache:, client:, cache_expiration:)
      end

      before do
        allow(client).to receive(:geocode).with(query).and_return(edinburgh_hash)
      end

      it "returns CoordinatesResult for Scotland location" do
        result = coordinates_query.call

        expect(result).to be_a(Geolocation::CoordinatesResult)
        expect(result.latitude).to eq(edinburgh.latitude)
        expect(result.longitude).to eq(edinburgh.longitude)
        expect(result.country).to eq("GB")
        expect(result.administrative_area_level_1).to eq("Scotland")
      end
    end

    context "when searching for Northern Ireland location" do
      let(:query) { "Belfast" }
      let(:belfast_hash) do
        {
          formatted_address: "Belfast, UK",
          latitude: belfast.latitude,
          longitude: belfast.longitude,
          country: "GB",
          postal_code: "BT1 2QQ",
          postal_town: "Belfast",
          route: "Donegall Place",
          locality: "Belfast",
          administrative_area_level_1: "Northern Ireland",
          administrative_area_level_4: "Belfast",
        }
      end

      let(:coordinates_query) do
        described_class.new(query, cache:, client:, cache_expiration:)
      end

      before do
        allow(client).to receive(:geocode).with(query).and_return(belfast_hash)
      end

      it "returns CoordinatesResult for Northern Ireland location" do
        result = coordinates_query.call

        expect(result).to be_a(Geolocation::CoordinatesResult)
        expect(result.latitude).to eq(belfast.latitude)
        expect(result.longitude).to eq(belfast.longitude)
        expect(result.country).to eq("GB")
        expect(result.administrative_area_level_1).to eq("Northern Ireland")
      end
    end

    context "when searching for Wales location" do
      let(:query) { "Cardiff" }
      let(:cardiff_hash) do
        {
          formatted_address: "Cardiff, UK",
          latitude: cardiff.latitude,
          longitude: cardiff.longitude,
          country: "GB",
          postal_code: "CF10 2HQ",
          postal_town: "Cardiff",
          route: "Castle Street",
          locality: "Cardiff",
          administrative_area_level_1: "Wales",
          administrative_area_level_4: "Cardiff",
        }
      end

      let(:coordinates_query) do
        described_class.new(query, cache:, client:, cache_expiration:)
      end

      before do
        allow(client).to receive(:geocode).with(query).and_return(cardiff_hash)
      end

      it "returns CoordinatesResult for Wales location" do
        result = coordinates_query.call

        expect(result).to be_a(Geolocation::CoordinatesResult)
        expect(result.latitude).to eq(cardiff.latitude)
        expect(result.longitude).to eq(cardiff.longitude)
        expect(result.country).to eq("GB")
        expect(result.administrative_area_level_1).to eq("Wales")
      end
    end
  end

  describe "#cache_key" do
    let(:query) { "London, UK" }

    it "returns the formatted cache key" do
      expect(coordinates_query.cache_key).to eq("geolocation:coordinates:v2:london-uk")
    end
  end

  describe "CoordinatesResult" do
    let(:common_hash) do
      {
        formatted_address: "London, UK",
        latitude: london.latitude,
        longitude: london.longitude,
        country: "GB",
        postal_code: "SW1A 1AA",
        postal_town: "London",
        route: "Parliament Street",
        locality: "London",
        administrative_area_level_1: "England",
        administrative_area_level_4: "City of Westminster",
        address_types: [],
      }
    end

    before do
      allow(client).to receive(:geocode).with(query).and_return(common_hash)
    end

    it "provides to_h" do
      result = coordinates_query.call

      expect(result.to_h).to eq(common_hash)
    end

    it "provides individual attribute readers" do
      result = coordinates_query.call

      expect(result.formatted_address).to eq("London, UK")
      expect(result.latitude).to eq(london.latitude)
      expect(result.longitude).to eq(london.longitude)
      expect(result.country).to eq("GB")
      expect(result.postal_code).to eq("SW1A 1AA")
      expect(result.postal_town).to eq("London")
      expect(result.route).to eq("Parliament Street")
      expect(result.locality).to eq("London")
      expect(result.administrative_area_level_1).to eq("England")
      expect(result.administrative_area_level_4).to eq("City of Westminster")
    end
  end
end
