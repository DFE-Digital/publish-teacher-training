# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleOldPlacesAPI::Client do
  let(:api_key) { '12345678910' }
  let(:client) { described_class.new(api_key:) }

  describe '#place_details' do
    let(:london_place_id) { 'ChIJdd4hrwug2EcRmSrV3Vo6llI' }
    let(:place_id) { london_place_id }
    let(:place_details_api_path) do
      "https://maps.googleapis.com/maps/api/place/details/json?fields=formatted_address,geometry&key=#{api_key}&place_id=#{place_id}"
    end
    let(:place_details_mock_response) do
      JSON.parse(Rails.root.join('spec/fixtures/api_responses/google_old_places_api_client/place-details.json').read)
    end

    context 'when success response' do
      before do
        stub_request(
          :get,
          place_details_api_path
        )
          .to_return(status: 200, body: place_details_mock_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the correct location and geometry' do
        result = client.place_details(place_id)

        expect(result).to eq(
          {
            location: '123 Some Street, Some City, Some Country',
            latitude: 12.345678,
            longitude: 98.765432
          }
        )
      end
    end

    context 'when no result is returned from the API' do
      before do
        stub_request(
          :get,
          place_details_api_path
        )
          .to_return(status: 200, body: '{}'.to_json, headers: {})
      end

      it 'returns nil' do
        result = client.place_details(place_id)

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
          place_details_api_path
        )
          .to_return(status: 200, body: '{}'.to_json, headers: {})
      end

      it 'filters the API key in the logs' do
        client.place_details(place_id)

        expect(log_contents.string).not_to include(api_key)
        expect(log_contents.string).to include('key=[FILTERED]')
      end
    end
  end
end
