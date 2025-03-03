# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleOldPlacesAPI::Client do
  let(:api_key) { '12345678910' }
  let(:client) { described_class.new(api_key:) }

  describe '#autocomplete' do
    let(:query) { 'London' }
    let(:autocomplete_api_path) do
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=#{api_key}&language=en&input=#{query}&components=country:uk&types=geocode"
    end

    context 'when success response' do
      before do
        stub_request(:get, autocomplete_api_path)
          .to_return(
            status: 200,
            body: file_fixture('google_old_places_api_client/autocomplete/london.json').read,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns an array of predictions' do
        result = client.autocomplete(query)

        expect(result).to eq(
          [
            {
              name: 'London, UK',
              formatted_name: 'London',
              place_id: 'ChIJdd4hrwug2EcRmSrV3Vo6llI',
              types: %w[locality political]
            }
          ]
        )
      end
    end

    context 'when no predictions are returned' do
      before do
        stub_request(:get, autocomplete_api_path)
          .to_return(status: 200, body: { predictions: [] }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns an empty array' do
        result = client.autocomplete(query)

        expect(result).to eq([])
      end
    end
  end

  describe '#geocode' do
    let(:query) { 'London' }
    let(:geocode_api_path) do
      "https://maps.googleapis.com/maps/api/geocode/json?key=#{api_key}&address=#{query}&components=country:UK&language=en"
    end

    context 'when success response' do
      before do
        stub_request(:get, geocode_api_path)
          .to_return(
            status: 200,
            body: file_fixture('google_old_places_api_client/geocode/london.json').read,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the correct location details' do
        result = client.geocode(query)

        expect(result).to eq(
          {
            formatted_address: 'London, UK',
            latitude: 51.5072178,
            longitude: -0.1275862,
            country: 'England',
            types: %w[locality political]
          }
        )
      end
    end

    context 'when no results are returned' do
      before do
        stub_request(:get, geocode_api_path)
          .to_return(status: 200, body: { results: [] }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns nil' do
        result = client.geocode(query)

        expect(result).to be_nil
      end
    end

    context 'when log output' do
      let(:log_contents) { StringIO.new }
      let(:logger) { Logger.new(log_contents) }
      let(:client) { described_class.new(api_key:, logger:, log_level: :debug) }

      before do
        stub_request(
          :get,
          geocode_api_path
        )
          .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'filters the API key in the logs' do
        client.geocode(query)

        expect(log_contents.string).not_to include(api_key)
        expect(log_contents.string).to include('key=[FILTERED]')
      end
    end

    context 'when searching for places in Scotland' do
      let(:query) { 'Edinburgh' }

      before do
        stub_request(:get, geocode_api_path)
          .to_return(
            status: 200,
            body: file_fixture('google_old_places_api_client/geocode/edinburgh.json').read,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the correct location details' do
        result = client.geocode(query)

        expect(result).to eq(
          {
            formatted_address: 'Edinburgh, UK',
            latitude: 55.953252,
            longitude: -3.188267,
            country: 'Scotland',
            types: %w[locality political]
          }
        )
      end
    end

    context 'when searching for places in Northern Ireland' do
      let(:query) { 'Belfast' }

      before do
        stub_request(:get, geocode_api_path)
          .to_return(
            status: 200,
            body: file_fixture('google_old_places_api_client/geocode/belfast.json').read,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the correct location details' do
        result = client.geocode(query)

        expect(result).to eq(
          {
            formatted_address: 'Belfast, UK',
            latitude: 54.59728500000001,
            longitude: -5.93012,
            country: 'Northern Ireland',
            types: %w[locality political]
          }
        )
      end
    end

    context 'when searching for places in Wales' do
      let(:query) { 'Cardiff' }

      before do
        stub_request(:get, geocode_api_path)
          .to_return(
            status: 200,
            body: file_fixture('google_old_places_api_client/geocode/cardiff.json').read,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the correct location details' do
        result = client.geocode(query)

        expect(result).to eq(
          {
            formatted_address: 'Cardiff, UK',
            latitude: 51.483707,
            longitude: -3.1680962,
            country: 'Wales',
            types: %w[locality political]
          }
        )
      end
    end
  end
end
