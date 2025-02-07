# frozen_string_literal: true

module Geolocation
  class CoordinatesQuery
    attr_reader :query, :logger, :cache, :client, :cache_expiration

    def initialize(query, logger: Rails.logger, cache: Rails.cache, client: GoogleOldPlacesAPI::Client.new, cache_expiration: 30.days)
      @query = query
      @logger = logger
      @cache = cache
      @client = client
      @cache_expiration = cache_expiration
    end

    # Retrieves the coordinates for the given location.
    # It first attempts to fetch the cached coordinates. If not found, it will fetch them
    # from the API and cache the result for future use.
    # @return [Hash] The coordinates, including latitude, longitude, and location.
    def call
      return blank_coordinates if query.blank?

      cached_coordinates || fetch_and_cache_coordinates
    end

    # Attempts to retrieve the cached coordinates using a cache key.
    # Logs the cache status (HIT or MISS).
    # @return [Hash, nil] The cached coordinates if found, nil otherwise.
    def cached_coordinates
      @cache.read(cache_key).tap do |cached_data|
        if cached_data
          logger.info("Cache HIT for: #{query}")
        else
          logger.info("Cache MISS for: #{query}")
        end
      end
    end

    # Fetches the coordinates from the API and caches them.
    # If the coordinates are invalid, it returns a default error response
    # because we don't want to interrupt the user flow. If getting coordinates
    # fails, the app won't return the results by location.
    # @return [Hash] The fetched coordinates or a default error response if invalid.
    def fetch_and_cache_coordinates
      response = fetch_coordinates
      return coordinates_on_error unless valid_coordinates?(response)

      cache_coordinates(response)

      response
    end

    # Makes a request to fetch coordinates using the `call` method.
    # This method is wrapped in a `rescue` block to handle any exceptions
    # during the API call.
    # @return [Hash, nil] The coordinates response from the API, or nil in case of an error.
    def fetch_coordinates
      @client.geocode(@query)
    rescue StandardError => e
      capture_error(e)
      nil
    end

    # Caches the fetched coordinates with the specified expiration time.
    # @param response [Hash] The coordinates response to be cached.
    def cache_coordinates(response)
      @cache.write(cache_key, response, expires_in: @cache_expiration)
    end

    # Returns a default error response when coordinates are invalid or an error occurs.
    # @return [Hash] A default error response with nil latitude, longitude, and location.
    def coordinates_on_error
      { latitude: nil, longitude: nil, formatted_address: nil, types: [] }
    end
    alias blank_coordinates coordinates_on_error

    # Validates whether the response from the API contains valid coordinates.
    # @param response [Hash] The response to validate.
    # @return [Boolean] True if the response contains valid latitude and longitude, false otherwise.
    def valid_coordinates?(response)
      response&.dig(:latitude).present? && response&.dig(:longitude).present?
    end

    # Captures any error that occurs during the location lookup process and logs it.
    # Additionally, it reports the error to Sentry for further monitoring and analysis.
    # @param error [StandardError] The error that occurred.
    def capture_error(error)
      message = "Location search failed for #{self.class} - #{query}, location search ignored (user experience unaffected)"

      logger.info(message)

      Sentry.capture_exception(
        error,
        message:
      )
    end

    def cache_key
      "geolocation:query:#{@query.parameterize}"
    end
  end
end
