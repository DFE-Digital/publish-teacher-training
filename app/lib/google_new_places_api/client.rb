module GoogleNewPlacesAPI
  class Client
    BASE_URL = 'https://places.googleapis.com/v1/'

    def initialize
      @api_key = Settings.google.places_api_key

      @connection = Faraday.new(url: BASE_URL) do |conn|
        conn.request :json
        conn.response :json, parser_options: { symbolize_names: true }
        conn.response :logger, Logger.new($stdout), { headers: false, bodies: true, formatter: Faraday::Logging::Formatter }
        conn.adapter Faraday.default_adapter
      end
    end

    def autocomplete(query)
      response = post(
        endpoint: 'places:autocomplete',
        body: {
          input: query,
          regionCode: 'GB',
          languageCode: 'en-GB',
          includedRegionCodes: ["uk"]
        },
        headers: { 'X-Goog-FieldMask' => '*' }
      )

      Array(response[:suggestions]).map do |suggestion|
        place_prediction = suggestion[:placePrediction]
        {
          name: place_prediction[:text][:text],
          location_id: place_prediction[:placeId],
          location_types: place_prediction[:types]
        }
      end
    end

    private

    def post(endpoint:, body:, headers: {})
      headers['X-Goog-Api-Key'] = @api_key

      response = @connection.post(endpoint) do |req|
        req.headers = headers
        req.body = body
      end

      response.body || {}
    rescue Faraday::Error => e
      Sentry.capture_message("Google Places API error - '#{response.status}', '#{response.body}'. Exception: '#{e}'")
      {}
    end
  end
end
