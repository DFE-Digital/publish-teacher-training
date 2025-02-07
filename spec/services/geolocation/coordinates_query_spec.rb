# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Geolocation::CoordinatesQuery do
  subject(:coordinates) { coordinates_query.call }

  let(:london) { build(:location, :london) }
  let(:manchester) { build(:location, :manchester) }
  let(:query) { 'London' }
  let(:client) { instance_double(GoogleOldPlacesAPI::Client) }
  let(:cache) { Rails.cache }
  let(:cache_expiration) { 30.days }

  let(:coordinates_query) do
    described_class.new(query, cache: cache, client: client, cache_expiration: cache_expiration)
  end

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe '#coordinates' do
    context 'when query is blank' do
      let(:query) { '' }

      it 'returns blank coordinates' do
        expect(coordinates).to eq({ latitude: nil, longitude: nil, formatted_address: nil, types: [] })
      end

      it 'does not cache' do
        coordinates_query.call

        expect(coordinates_query.cached_coordinates).to be_nil
      end
    end

    context 'when coordinates are cached' do
      let(:cached_coordinates) do
        { latitude: london.latitude, longitude: london.longitude, formatted_address: 'London', types: %w[locality political] }
      end

      before do
        coordinates_query.cache_coordinates(cached_coordinates)
      end

      it 'returns the cached coordinates' do
        expect(coordinates).to eq(cached_coordinates)
        expect(coordinates_query.cache.read(coordinates_query.cache_key)).to eq(cached_coordinates)
      end

      it 'logs a cache hit' do
        expect(Rails.logger).to receive(:info).with("Cache HIT for: #{query}")
        coordinates
      end
    end

    context 'when coordinates are not cached' do
      let(:response) do
        { latitude: manchester.latitude, longitude: manchester.longitude, formatted_address: 'Manchester', types: %w[locality political] }
      end

      before do
        allow(coordinates_query).to receive(:fetch_coordinates).and_return(response)
      end

      it 'fetches and caches the coordinates' do
        expect(Rails.cache.read(coordinates_query.cache_key)).to be_nil

        expect(coordinates_query.call).to eq(response)

        expect(Rails.cache.read(coordinates_query.cache_key)).to eq(response)
      end

      it 'logs a cache miss' do
        expect(Rails.logger).to receive(:info).with("Cache MISS for: #{query}")
        coordinates
      end
    end

    context 'when geocoding search results in an error' do
      it 'returns coordinates_on_error' do
        allow(coordinates_query).to receive(:fetch_coordinates).and_return(nil)
        expect(coordinates).to eq({ latitude: nil, longitude: nil, formatted_address: nil, types: [] })
      end

      it 'captures the error in Sentry' do
        allow(coordinates_query.client).to receive(:geocode).and_raise(StandardError, 'Geocoding failed')
        allow(Sentry).to receive(:capture_exception)

        coordinates

        expect(Sentry).to have_received(:capture_exception).with(
          instance_of(StandardError),
          hash_including(message: 'Location search failed for Geolocation::CoordinatesQuery - London, location search ignored (user experience unaffected)')
        )
      end
    end

    context 'when coordinates are fetched from GoogleOldPlacesAPI' do
      let(:google_response) do
        {
          latitude: london.latitude,
          longitude: london.longitude,
          formatted_address: 'London, UK',
          types: %w[locality political]
        }
      end

      before do
        allow(cache).to receive(:read).with(coordinates_query.cache_key).and_return(nil)
        allow(client).to receive(:geocode).with(query).and_return(google_response)
        allow(Rails.cache).to receive(:write).and_call_original
      end

      it 'fetches coordinates from GoogleOldPlacesAPI and caches them' do
        coordinates = { latitude: london.latitude, longitude: london.longitude, formatted_address: 'London, UK', types: %w[locality political] }
        expect(coordinates_query.call).to eq(coordinates)

        expect(cache).to have_received(:write).with(coordinates_query.cache_key, coordinates, expires_in: cache_expiration)
      end

      it 'logs the cache miss when coordinates are fetched' do
        expect(Rails.logger).to receive(:info).with("Cache MISS for: #{query}")
        coordinates
      end
    end
  end

  describe '#cache_key' do
    let(:query) { 'London, UK' }

    it 'returns the formatted cache key' do
      expect(coordinates_query.cache_key).to eq('geolocation:query:london-uk')
    end
  end
end
