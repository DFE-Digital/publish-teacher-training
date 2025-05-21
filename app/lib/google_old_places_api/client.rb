# frozen_string_literal: true

module GoogleOldPlacesAPI
  # Wrapper around Google REST APIs for Geocoding and Autocomplete
  #
  class Client
    BASE_URL = "https://maps.googleapis.com/maps/api/"

    def initialize(api_key: Settings.google.gcp_api_key, logger: Rails.logger, log_level: Rails.logger.level)
      @api_key = api_key
      @connection = Faraday.new(BASE_URL) do |f|
        f.adapter :net_http_persistent
        f.response(:logger, logger, { headers: false, bodies: true, formatter: Faraday::Logging::Formatter, log_level: }) do |log|
          log.filter(@api_key, "[FILTERED]")
        end
        f.response :json
      end
    end

    # @see https://developers.google.com/maps/documentation/places/web-service/autocomplete
    def autocomplete(query)
      response = get(
        endpoint: "place/autocomplete/json",
        params: {
          key: @api_key,
          language: "en",
          input: query,
          components: "country:uk",
          types: "geocode",
        },
      )

      Array(response["predictions"]).map do |prediction|
        {
          name: prediction["description"],
          place_id: prediction["place_id"],
          types: prediction["types"],
        }
      end
    end

    # @see https://developers.google.com/maps/documentation/geocoding/start
    def geocode(location_name)
      response = get(
        endpoint: "geocode/json",
        params: {
          key: @api_key,
          address: location_name,
          components: "country:UK",
          language: "en",
        },
      )

      result = response.dig("results", 0)
      return if result.blank?

      {
        formatted_address: result["formatted_address"],
        latitude: result.dig("geometry", "location", "lat"),
        longitude: result.dig("geometry", "location", "lng"),
        country: extract_country(result),
        types: result["types"],
      }
    end

    # @see https://developers.google.com/maps/documentation/places/web-service/search-find-place
    def find_place(query, fields: %w[place_id formatted_address name geometry])
      response = get(
        endpoint: "place/findplacefromtext/json",
        params: {
          key: @api_key,
          input: query,
          inputtype: "textquery",
          fields: fields.join(","),
          language: "en",
          locationbias: "country:UK",
        },
      )

      candidates = Array(response["candidates"])
      return [] if candidates.empty?

      candidates.map do |candidate|
        {
          place_id: candidate["place_id"],
          name: candidate["name"],
          formatted_address: candidate["formatted_address"],
          latitude: candidate.dig("geometry", "location", "lat"),
          longitude: candidate.dig("geometry", "location", "lng"),
        }.compact
      end
    end

    # @see https://developers.google.com/maps/documentation/places/web-service/details
    def place_details(place_id, fields: nil)
      params = {
        key: @api_key,
        place_id: place_id,
        language: "en",
      }

      # Add fields parameter if specific fields are requested
      params[:fields] = fields.join(",") if fields.present?

      response = get(
        endpoint: "place/details/json",
        params:,
      )

      result = response["result"]
      return if result.blank?

      {
        name: result["name"],
        place_id: result["place_id"],
        formatted_address: result["formatted_address"],
        types: result["types"],
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

    def extract_country(result)
      address_components = Array(result["address_components"]).pluck("long_name")

      (address_components & (DEVOLVED_NATIONS + %w[England])).first
    end
  end
end
