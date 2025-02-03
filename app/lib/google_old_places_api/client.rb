module GoogleOldPlacesAPI
  class Client
    BASE_URL = 'https://maps.googleapis.com/maps/api/place/'

    def initialize
      @api_key = Settings.google.places_api_key

      @connection = Faraday.new(BASE_URL) do |f|
        f.adapter :net_http_persistent
        f.response :logger, Logger.new($stdout), { headers: false, bodies: true, formatter: Faraday::Logging::Formatter }
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
