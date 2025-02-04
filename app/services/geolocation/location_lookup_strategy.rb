# frozen_string_literal: true

module Geolocation
  class LocationLookupStrategy
    attr_reader :location, :logger, :cache, :client, :cache_expiration

    def initialize(location, logger: Rails.logger, cache: Rails.cache, client: GoogleOldPlacesAPI::Client.new, cache_expiration: 30.days)
      @location = location
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
          logger.info("Cache HIT for location: #{location}")
        else
          logger.info("Cache MISS for location: #{location}")
        end
      end
    end

    def fetch_and_cache_coordinates
      response = fetch_coordinates
      return coordinates_on_error unless valid_coordinates?(response)

      cache_coordinates(response)

      response
    end

    def cache_coordinates(response)
      @cache.write(cache_key, response, expires_in: @cache_expiration)
    end

    def coordinates_on_error
      { latitude: nil, longitude: nil, location: nil }
    end

    def valid_coordinates?(response)
      response&.dig(:latitude).present? && response&.dig(:longitude).present?
    end

    def capture_error(error)
      message = "Location search failed for #{self.class} - #{location}, location search ignored (user experience unaffected)"

      logger.info(message)

      Sentry.capture_exception(
        error,
        message:
      )
    end
  end
end
