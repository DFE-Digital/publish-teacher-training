# frozen_string_literal: true

class LocationSuggestion
  CACHE_EXPIRY = 30.minutes

  class << self
    def suggest(input)
      query = build_query(input)
      cached_result = Rails.cache.read(location_query_cache_key(input))
      return cached_result unless cached_result.nil?

      response = connection.get("#{Settings.google.places_api_path}?#{query.to_query}")

      if do_not_cache?(response)
        report_error(response)
        return
      end

      result = response.body["predictions"].map(&format_prediction).take(5)
      Rails.cache.write(location_query_cache_key(input), result, expires_in: CACHE_EXPIRY)
      result
    end

  private

    def do_not_cache?(response)
      response.status != 200 ||
        response.body["error_message"].present? ||
        response.body["predictions"].blank?
    end

    def report_error(response)
      Sentry.capture_message("Google Places API error - status: #{response.status}, body: #{response.body}") if response.status != 200 || response.body["error_message"].present?
    end

    def location_query_cache_key(input)
      "location-query-#{input.upcase}"
    end

    def connection
      Faraday.new(Settings.google.places_api_host) do |f|
        f.adapter :net_http_persistent
        f.response :json
      end
    end

    def format_prediction
      lambda do |prediction|
        prediction_split = prediction["description"].split(",")
        prediction_split.first(prediction_split.size - 1).join(",")
      end
    end

    def build_query(input)
      {
        key: Settings.google.gcp_api_key,
        language: "en",
        input:,
        components: "country:uk",
        types: "geocode",
      }
    end
  end
end
