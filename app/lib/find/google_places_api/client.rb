# frozen_string_literal: true

require 'faraday'
require 'faraday/logging/formatter'

module Find
  module GooglePlacesAPI
    class Client
      BASE_URL = 'https://places.googleapis.com/v1/'
#      DEFAULT_FIELD_MASK = "displayName,formattedAddress,location.latitude,location.longitude"
      DEFAULT_FIELD_MASK = '*'

      def initialize(api_key: Settings.google.places_api_key)
        @api_key = api_key
        @connection = Faraday.new(url: BASE_URL) do |conn|
          conn.request :json
          conn.response :json, parser_options: { symbolize_names: true }
          conn.response :logger, Logger.new($stdout), { headers: false, bodies: true, formatter: Faraday::Logging::Formatter }
          conn.adapter Faraday.default_adapter
        end
      end

      def autocomplete(query:, field_mask: DEFAULT_FIELD_MASK)
        post(
          endpoint: 'places:autocomplete',
          body: {
            input: query,
            regionCode: 'GB',
            includedRegionCodes: ["uk"]
          },
          headers: { 'X-Goog-FieldMask' => field_mask }
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
        Sentry.capture_message(
          "Google Places API error - '#{response.status}', '#{response.body}'. Exception: '#{e}'"
        )
        {}
      end
    end
  end
end
