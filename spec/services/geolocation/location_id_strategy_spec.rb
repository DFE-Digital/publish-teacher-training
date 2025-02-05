# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Geolocation::LocationIdStrategy do
  subject(:coordinates) { strategy.coordinates }

  let(:london) { build(:location, :london) }
  let(:manchester) { build(:location, :manchester) }
  let(:location) { 'google-place-id' }
  let(:client) { instance_double(GoogleOldPlacesAPI::Client) }
  let(:cache) { Rails.cache }
  let(:cache_expiration) { 30.days }

  let(:strategy) do
    described_class.new(location, cache: cache, client: client, cache_expiration: cache_expiration)
  end

  describe '#coordinates' do
    context 'when coordinates are cached' do
      let(:cached_coordinates) do
        { latitude: london.latitude, longitude: london.longitude, location: 'London', location_types: %w[locality political] }
      end

      before do
        allow(cache).to receive(:read).with(strategy.cache_key).and_return(cached_coordinates)
      end

      it 'returns the cached coordinates' do
        expect(coordinates).to eq(cached_coordinates)
      end
    end

    context 'when coordinates are not cached' do
      let(:response) do
        { latitude: manchester.latitude, longitude: manchester.longitude, location: 'Manchester', location_types: %w[locality political] }
      end

      before do
        allow(cache).to receive(:read).with(strategy.cache_key).and_return(nil)
        allow(strategy).to receive(:fetch_and_cache_coordinates).and_return(response)
      end

      it 'fetches and caches the coordinates' do
        expect(coordinates).to eq(response)
      end
    end

    context 'when fetching coordinates results in an error' do
      before do
        allow(cache).to receive(:read).with(strategy.cache_key).and_return(nil)
      end

      it 'returns coordinates_on_error' do
        allow(strategy).to receive(:fetch_coordinates).and_return(nil)
        expect(coordinates).to eq({ latitude: nil, longitude: nil, location: nil, location_types: [] })
      end

      it 'captures the error in Sentry' do
        allow(strategy.client).to receive(:place_details).and_raise(StandardError, 'API failed')
        allow(Sentry).to receive(:capture_exception)

        coordinates

        expect(Sentry).to have_received(:capture_exception).with(
          instance_of(StandardError),
          hash_including(message: 'Location search failed for Geolocation::LocationIdStrategy - google-place-id, location search ignored (user experience unaffected)')
        )
      end
    end
  end
end
