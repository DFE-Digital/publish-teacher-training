# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Geolocation::Resolver do
  let(:london) { build(:location, :london) }
  let(:manchester) { build(:location, :manchester) }

  describe '#resolve' do
    context 'when place_id is present' do
      let(:place_id) { 'some-google-place-id' }
      let(:resolver) { described_class.new(place_id:, query: nil) }

      it 'uses the PlaceIdStrategy to get coordinates' do
        strategy = instance_double(Geolocation::PlaceIdStrategy)
        allow(Geolocation::PlaceIdStrategy).to receive(:new).with(place_id).and_return(strategy)
        allow(strategy).to receive(:coordinates).and_return({ latitude: london.latitude, longitude: london.longitude, formatted_address: 'London' })

        expect(resolver.call).to eq({ latitude: london.latitude, longitude: london.longitude, formatted_address: 'London' })
      end
    end

    context 'when location id is not present but location name is present' do
      let(:resolver) { described_class.new(place_id: nil, query: 'Manchester') }

      it 'uses the QueryStrategy to get coordinates' do
        strategy = instance_double(Geolocation::QueryStrategy)
        allow(Geolocation::QueryStrategy).to receive(:new).with('Manchester').and_return(strategy)
        allow(strategy).to receive(:coordinates).and_return({ latitude: manchester.latitude, longitude: manchester.longitude, formatted_address: 'Manchester' })

        expect(resolver.call).to eq({ latitude: manchester.latitude, longitude: manchester.longitude, formatted_address: 'Manchester' })
      end
    end

    context 'when neither place_id nor location is present' do
      let(:resolver) { described_class.new(place_id: nil, query: nil) }

      it 'uses the NullStrategy and returns blank coordinates' do
        expect(resolver.call).to eq({ latitude: nil, longitude: nil, formatted_address: nil, types: [] })
      end
    end

    context 'when no arguments' do
      let(:resolver) { described_class.new }

      it 'uses the NullStrategy and returns blank coordinates' do
        expect(resolver.call).to eq({ latitude: nil, longitude: nil, formatted_address: nil, types: [] })
      end
    end
  end
end
