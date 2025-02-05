# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Geolocation::Resolver do
  let(:london) { build(:location, :london) }
  let(:manchester) { build(:location, :manchester) }

  describe '#resolve' do
    context 'when place_id is present' do
      let(:place_id) { 'some-google-place-id' }
      let(:resolver) { described_class.new(place_id:, query: nil) }

      it 'uses the LocationIdStrategy to get coordinates' do
        strategy = instance_double(Geolocation::LocationIdStrategy)
        allow(Geolocation::LocationIdStrategy).to receive(:new).with(place_id).and_return(strategy)
        allow(strategy).to receive(:coordinates).and_return({ latitude: london.latitude, longitude: london.longitude, location: 'London' })

        expect(resolver.call).to eq({ latitude: london.latitude, longitude: london.longitude, location: 'London' })
      end
    end

    context 'when location id is not present but location name is present' do
      let(:resolver) { described_class.new(place_id: nil, query: 'Manchester') }

      it 'uses the LocationNameStrategy to get coordinates' do
        strategy = instance_double(Geolocation::LocationNameStrategy)
        allow(Geolocation::LocationNameStrategy).to receive(:new).with('Manchester').and_return(strategy)
        allow(strategy).to receive(:coordinates).and_return({ latitude: manchester.latitude, longitude: manchester.longitude, location: 'Manchester' })

        expect(resolver.call).to eq({ latitude: manchester.latitude, longitude: manchester.longitude, location: 'Manchester' })
      end
    end

    context 'when neither place_id nor location is present' do
      let(:resolver) { described_class.new(place_id: nil, query: nil) }

      it 'uses the NullStrategy and returns blank coordinates' do
        expect(resolver.call).to eq({ latitude: nil, longitude: nil, location: nil })
      end
    end

    context 'when no arguments' do
      let(:resolver) { described_class.new }

      it 'uses the NullStrategy and returns blank coordinates' do
        expect(resolver.call).to eq({ latitude: nil, longitude: nil, location: nil })
      end
    end
  end
end
