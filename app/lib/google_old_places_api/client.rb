# frozen_string_literal: true

module GoogleOldPlacesAPI
  class Client
    BASE_URL = 'https://maps.googleapis.com/maps/api/'

    def initialize(api_key: Settings.google.gcp_api_key, logger: Rails.logger, log_level: Rails.logger.level)
      @api_key = api_key
      @connection = Faraday.new(BASE_URL) do |f|
        f.adapter :net_http_persistent
        f.response(:logger, logger, { headers: false, bodies: true, formatter: Faraday::Logging::Formatter, log_level: }) do |log|
          log.filter(@api_key, '[FILTERED]')
        end
        f.response :json
      end
    end

    def autocomplete(query)
      response = get(
        endpoint: 'place/autocomplete/json',
        params: {
          key: @api_key,
          language: 'en',
          input: query,
          components: 'country:uk',
          types: 'geocode'
        }
      )

      Array(response['predictions']).map do |prediction|
        {
          name: prediction['description'],
          location_id: prediction['place_id'],
          location_types: prediction['types']
        }
      end
    end

    def place_details(place_id)
      response = get(
        endpoint: 'place/details/json',
        params: {
          key: @api_key,
          place_id: place_id,
          fields: 'formatted_address,geometry'
        }
      )
      result = response['result']

      return if result.blank?

      {
        location: result['formatted_address'],
        latitude: result.dig('geometry', 'location', 'lat'),
        longitude: result.dig('geometry', 'location', 'lng')
      }
    end

    def geocode(location_name)
      response = get(
        endpoint: 'geocode/json',
        params: {
          key: @api_key,
          address: location_name,
          components: 'country:UK',
          language: 'en'
        }
      )

      result = response.dig('results', 0)
      return if result.blank?

      {
        location: result['formatted_address'],
        latitude: result.dig('geometry', 'location', 'lat'),
        longitude: result.dig('geometry', 'location', 'lng')
      }
    end

    private

    def get(endpoint:, params:)
      response = @connection.get(endpoint, params)

      response.body || {}
    rescue Faraday::Error => e
      Sentry.capture_message("Google Places (Old) API error - '#{response.status}', '#{response.body}'. Exception: '#{e}'")
      {}
    end
  end
end
