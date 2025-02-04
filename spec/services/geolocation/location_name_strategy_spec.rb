# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Geolocation::LocationNameStrategy do
  subject(:coordinates) { strategy.coordinates }

  let(:london) { build(:location, :london) }
  let(:manchester) { build(:location, :manchester) }
  let(:location_name) { 'London' }
  let(:client) { instance_double(GoogleOldPlacesAPI::Client) }
  let(:cache) { Rails.cache }
  let(:cache_expiration) { 30.days }

  let(:strategy) do
    described_class.new(location_name, cache: cache, client: client, cache_expiration: cache_expiration)
  end

  describe '#coordinates' do
    context 'when coordinates are cached' do
      let(:cached_coordinates) { { latitude: london.latitude, longitude: london.longitude, location: 'London' } }

      before do
        allow(cache).to receive(:read).with(strategy.cache_key).and_return(cached_coordinates)
      end

      it 'returns the cached coordinates' do
        expect(coordinates).to eq(cached_coordinates)
      end

      it 'logs a cache hit' do
        expect(Rails.logger).to receive(:info).with("Cache HIT for location_name: #{location_name}")
        coordinates
      end
    end

    context 'when coordinates are not cached' do
      let(:response) { { latitude: manchester.latitude, longitude: manchester.longitude, location: 'Manchester' } }

      before do
        allow(cache).to receive(:read).with(strategy.cache_key).and_return(nil)
        allow(strategy).to receive(:fetch_and_cache_coordinates).and_return(response)
      end

      it 'fetches and caches the coordinates' do
        expect(coordinates).to eq(response)
      end

      it 'logs a cache miss' do
        expect(Rails.logger).to receive(:info).with("Cache MISS for location_name: #{location_name}")
        coordinates
      end
    end

    context 'when geocoding search results in an error' do
      before do
        allow(cache).to receive(:read).with(strategy.cache_key).and_return(nil)
      end

      it 'returns coordinates_on_error' do
        allow(strategy).to receive(:fetch_coordinates).and_return(nil)
        expect(coordinates).to eq({ latitude: nil, longitude: nil, location: nil })
      end

      it 'captures the error in Sentry' do
        allow(strategy.client).to receive(:geocode).and_raise(StandardError, 'Geocoding failed')
        allow(Sentry).to receive(:capture_exception)

        coordinates

        expect(Sentry).to have_received(:capture_exception).with(
          instance_of(StandardError),
          hash_including(message: 'Geocoding search failed, location search ignored (user experience unaffected)')
        )
      end
    end

    context 'when coordinates are fetched from GoogleOldPlacesAPI' do
      let(:google_response) do
        {
          latitude: london.latitude,
          longitude: london.longitude,
          location: 'London, UK'
        }
      end

      before do
        allow(cache).to receive(:read).with(strategy.cache_key).and_return(nil)
        allow(client).to receive(:geocode).with(location_name).and_return(google_response)
        allow(Rails.cache).to receive(:write).and_call_original
      end

      it 'fetches coordinates from GoogleOldPlacesAPI and caches them' do
        coordinates = { latitude: london.latitude, longitude: london.longitude, location: 'London, UK' }
        expect(strategy.coordinates).to eq(coordinates)

        expect(cache).to have_received(:write).with(strategy.cache_key, coordinates, expires_in: cache_expiration)
      end

      it 'logs the cache miss when coordinates are fetched' do
        expect(Rails.logger).to receive(:info).with("Cache MISS for location_name: #{location_name}")
        coordinates
      end
    end
  end
end
