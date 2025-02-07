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
    let(:autocomplete_mock_response) do
      JSON.parse(Rails.root.join('spec/fixtures/api_responses/google_old_places_api_client/autocomplete.json').read)
    end

    context 'when success response' do
      before do
        stub_request(:get, autocomplete_api_path)
          .to_return(status: 200, body: autocomplete_mock_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns an array of predictions' do
        result = client.autocomplete(query)

        expect(result).to eq(
          [
            {
              name: 'London, UK',
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
    let(:geocode_mock_response) do
      JSON.parse(Rails.root.join('spec/fixtures/api_responses/google_old_places_api_client/geocode.json').read)
    end

    context 'when success response' do
      before do
        stub_request(:get, geocode_api_path)
          .to_return(status: 200, body: geocode_mock_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the correct location details' do
        result = client.geocode(query)

        expect(result).to eq(
          {
            formatted_address: 'London, UK',
            latitude: 51.5074,
            longitude: -0.1278,
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
  end
end
