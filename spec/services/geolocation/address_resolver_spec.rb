# frozen_string_literal: true

require "rails_helper"

RSpec.describe Geolocation::AddressResolver do
  let(:london) { build(:location, :london) }
  let(:manchester) { build(:location, :manchester) }
  let(:edinburgh) { build(:location, :edinburgh) }
  let(:belfast) { build(:location, :belfast) }
  let(:cardiff) { build(:location, :cardiff) }

  let(:query) { "London" }
  let(:client) { instance_double(GoogleOldPlacesAPI::Client) }
  let(:cache) { Rails.cache }
  let(:cache_expiration) { 30.days }

  let(:address_resolver) do
    described_class.new(query, logger: Rails.logger, cache:, client:, cache_expiration:)
  end

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe "#call" do
    context "when query is blank" do
      let(:query) { "" }

      it "returns blank address" do
        expect(address_resolver.call).to eq(
          {
            latitude: nil,
            longitude: nil,
            country: nil,
            formatted_address: nil,
            address_types: [],
          },
        )
      end

      it "does not cache" do
        address_resolver.call

        expect(cache.read(address_resolver.cache_key)).to be_nil
      end
    end

    context "when results do not return latitude" do
      before do
        allow(client).to receive(:geocode).and_return(formatted_address: "An address", latitude: nil)
      end

      it "returns blank address" do
        expect(address_resolver.call).to eq(
          {
            latitude: nil,
            longitude: nil,
            country: nil,
            formatted_address: nil,
            address_types: [],
          },
        )
      end

      it "does not cache" do
        address_resolver.call

        expect(cache.read(address_resolver.cache_key)).to be_nil
      end
    end

    context "when results do not return longitude" do
      before do
        allow(client).to receive(:geocode).and_return(formatted_address: "An address", longitude: nil)
      end

      it "returns blank address" do
        expect(address_resolver.call).to eq(
          {
            latitude: nil,
            longitude: nil,
            country: nil,
            formatted_address: nil,
            address_types: [],
          },
        )
      end

      it "does not cache" do
        address_resolver.call

        expect(cache.read(address_resolver.cache_key)).to be_nil
      end
    end

    context "when address are cached" do
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
        cache.write(address_resolver.cache_key, cached_hash, expires_in: cache_expiration)
      end

      it "returns address from cached hash" do
        expect(address_resolver.call).to eq(cached_hash)
      end

      it "logs a cache hit" do
        expect(Rails.logger).to receive(:info).with(
          "Cache HIT for: '#{query}' | Key: geolocation:address_resolver:london | Cached: #{cached_hash.inspect}",
        )
        address_resolver.call
      end
    end

    context "when address are not cached" do
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

      it "fetches and caches the address" do
        expect(cache.read(address_resolver.cache_key)).to be_nil

        result = address_resolver.call

        expect(result.slice(:latitude, :longitude)).to eq(
          {
            latitude: manchester.latitude,
            longitude: manchester.longitude,
          },
        )

        expect(cache.read(address_resolver.cache_key)).to eq(common_hash)
      end

      it "logs a cache miss" do
        expect(Rails.logger).to receive(:info).with(
          "Cache MISS for: '#{query}' | Key: geolocation:address_resolver:manchester",
        )
        address_resolver.call
      end
    end

    context "when geocoding search results in an error" do
      it "returns blank address" do
        allow(client).to receive(:geocode).with(query).and_return(nil)
        expect(address_resolver.call).to eq(
          {
            latitude: nil,
            longitude: nil,
            country: nil,
            formatted_address: nil,
            address_types: [],
          },
        )
      end

      it "captures the error in Sentry" do
        allow(client).to receive(:geocode).and_raise(StandardError, "Geocoding failed")
        allow(Sentry).to receive(:capture_exception)

        address_resolver.call

        expect(Sentry).to have_received(:capture_exception).with(
          instance_of(StandardError),
          hash_including(
            message: "Location search failed for Geolocation::AddressResolver - #{query}, location search ignored (user experience unaffected)",
          ),
        )
      end
    end

    context "when address are fetched from GoogleOldPlacesAPI" do
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

      it "caches the normalized common hash" do
        address_resolver.call

        expect(Rails.cache.read(address_resolver.cache_key)).to eq(common_hash)
      end

      it "wraps hash in CoordinatesResult" do
        expect(address_resolver.call).to eq(common_hash)
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
        expect(address_resolver.call).to eq(london_hash)
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

      before do
        allow(client).to receive(:geocode).with(query).and_return(edinburgh_hash)
      end

      it "returns CoordinatesResult for Scotland location" do
        expect(address_resolver.call).to eq(edinburgh_hash)
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

      before do
        allow(client).to receive(:geocode).with(query).and_return(belfast_hash)
      end

      it "returns CoordinatesResult for Northern Ireland location" do
        expect(address_resolver.call).to eq(belfast_hash)
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

      before do
        allow(client).to receive(:geocode).with(query).and_return(cardiff_hash)
      end

      it "returns CoordinatesResult for Wales location" do
        expect(address_resolver.call).to eq(cardiff_hash)
      end
    end
  end

  describe "#cache_key" do
    let(:query) { "London, UK" }

    it "returns the formatted cache key" do
      expect(address_resolver.cache_key).to eq("geolocation:address_resolver:london-uk")
    end
  end
end
