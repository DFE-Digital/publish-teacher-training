module Find
  class LocationSuggestions
    attr_reader :input, :suggestions, :matched_terms

    def initialize(input, suggestion_strategy: GoogleNewPlacesAPI::Client.new)
      @input = input
      @suggestion_strategy = suggestion_strategy
    end

    def call
      @suggestion_strategy.autocomplete(input)
    end
  end
end

module Find
  module GoogleOldPlacesAPI
    class Client
      BASE_URL = 'https://maps.googleapis.com/maps/api/place/'

      def initialize
        @connection = Faraday.new(Settings.google.places_api_host) do |f|
          f.adapter :net_http_persistent
          f.response :json
        end
      end

      def autocomplete(query)
        get(
          endpoint: 'autocomplete/json',
          params: {
            key: @api_key,
            language: 'en',
            input: query,
            components: 'country:uk',
            types: 'geocode'
          }
        )
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
end

module Find
  module GoogleNewPlacesAPI
    class Client
      BASE_URL = 'https://places.googleapis.com/v1/'

      def initialize
        @api_key = Settings.google.places_api_key

        @connection = Faraday.new(url: base_url) do |conn|
          conn.request :json
          conn.response :json, parser_options: { symbolize_names: true }
          conn.response :logger, Logger.new($stdout), { headers: false, bodies: true, formatter: Faraday::Logging::Formatter }
          conn.adapter Faraday.default_adapter
        end
      end

      def autocomplete(query)
        post(
          endpoint: 'places:autocomplete',
          body: {
            input: query,
            regionCode: 'GB',
            languageCode: 'en-GB',
            includedRegionCodes: ["uk"]
          },
          headers: { 'X-Goog-FieldMask' => '*' }
        )
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
end

#Find::LocationSuggestions.new('London').call
#Find::LocationSuggestions.new('London', suggestion_strategy: Find::GoogleOldPlacesAPI::Client.new).call

#Both needs to return the same format of structure
