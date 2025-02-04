# frozen_string_literal: true

module Geolocation
  class LocationIdStrategy
    attr_reader :location_id, :logger, :cache, :client, :cache_expiration

    def initialize(location_id, logger: Rails.logger, cache: Rails.cache, client: GoogleOldPlacesAPI::Client.new, cache_expiration: 30.days)
      @location_id = location_id
      @logger = logger
      @cache = cache
      @client = client
      @cache_expiration = cache_expiration
    end

    def coordinates
      cached_coordinates || fetch_and_cache_coordinates
    end

    def cached_coordinates
      @cache.read(cache_key).tap do |cached_data|
        if cached_data
          logger.info("Cache HIT for location_id: #{@location_id}")
        else
          logger.info("Cache MISS for location_id: #{@location_id}")
        end
      end
    end

    def cache_key
      "geolocation:location_id:#{@location_id}"
    end

    def fetch_and_cache_coordinates
      response = fetch_coordinates
      return coordinates_on_error unless valid_coordinates?(response)

      cache_coordinates(response)

      response
    end

    def fetch_coordinates
      @client.place_details(@location_id)
    rescue StandardError => e
      capture_sentry_error(e)
      nil
    end

    private

    def cache_coordinates(response)
      @cache.write(cache_key, response, expires_in: @cache_expiration)
    end

    def capture_sentry_error(error)
      Sentry.capture_exception(
        error,
        message: 'Google Places API failed, location search ignored (user experience unaffected)'
      )
    end

    def coordinates_on_error
      { latitude: nil, longitude: nil, location: nil }
    end

    def valid_coordinates?(response)
      response&.dig(:latitude).present? && response&.dig(:longitude).present?
    end
  end
end
