# frozen_string_literal: true

module GoogleOldPlacesAPI
  class Client
    BASE_URL = 'https://maps.googleapis.com/maps/api/place/'

    def initialize(api_key: Settings.google.places_api_key, logger: Rails.logger, log_level: Rails.logger.level)
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
        endpoint: 'autocomplete/json',
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
        endpoint: 'details/json',
        params: {
          key: @api_key,
          place_id: place_id,
          fields: 'formatted_address,geometry'
        }
      )

      return if response['result'].blank?

      {
        location: response['result']['formatted_address'],
        latitude: response['result']['geometry']['location']['lat'],
        longitude: response['result']['geometry']['location']['lng']
      }
    end

    def geocode(location_name)
      search(location_name, components: 'country:UK').first

      { latitude: result.latitude, longitude: result.longitude, location: result.address }
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
