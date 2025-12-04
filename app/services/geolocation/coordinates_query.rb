# frozen_string_literal: true

module Geolocation
  # Geocode a location query into normalized coordinates.
  #
  # Handles caching of geocoding results and wraps the response in a
  # {CoordinatesResult} object. Normalizes provider-specific API responses
  # into a common hash format, ensuring location service agnosticism.
  #
  # @example
  #   query = Geolocation::CoordinatesQuery.new("London")
  #   result = query.call
  #   # => #<Geolocation::CoordinatesResult latitude=51.5, longitude=-0.1, ...>
  #
  # @attr_reader query [String] The location query string
  # @attr_reader logger [Logger] Logger instance for debug/info output
  # @attr_reader cache [ActiveSupport::Cache::Store] Cache store for results
  # @attr_reader client [GoogleOldPlacesAPI::Client] Geocoding API client
  # @attr_reader cache_expiration [ActiveSupport::Duration] Cache TTL
  class CoordinatesQuery
    attr_reader :query, :logger, :cache, :client, :cache_expiration

    # Initialize a new geocoding query.
    #
    # @param query [String] The location to geocode
    # @param logger [Logger] Rails logger (default: Rails.logger)
    # @param cache [ActiveSupport::Cache::Store] Cache store (default: Rails.cache)
    # @param client [#geocode] Geocoding API client (default: GoogleOldPlacesAPI::Client.new)
    # @param cache_expiration [ActiveSupport::Duration] Cache TTL (default: 30.days)
    def initialize(
      query,
      logger: Rails.logger,
      cache: Rails.cache,
      client: GoogleOldPlacesAPI::Client.new,
      cache_expiration: 30.days
    )
      @query = query
      @logger = logger
      @cache = cache
      @client = client
      @cache_expiration = cache_expiration
    end

    # Geocode the query with caching.
    #
    # @return [CoordinatesResult] Coordinates wrapped in result object
    def call
      return blank_result if query.blank?

      cached_hash = cache.read(cache_key)

      if cached_hash.present?
        log("Cache HIT for: '#{query}' | Key: #{cache_key} | Cached: #{cached_hash.inspect}")

        return CoordinatesResult.new(**cached_hash)
      end

      fetch_and_cache
    end

    def fetch_and_cache
      coordinates = fetch_coordinates
      return blank_result unless valid_coordinates?(coordinates)

      cache.write(cache_key, coordinates, expires_in: @cache_expiration)

      log("Cache MISS for: '#{query}' | Key: #{cache_key} | Caching: #{coordinates.inspect}")

      CoordinatesResult.new(**coordinates)
    end

    def valid_coordinates?(coordinates)
      coordinates.present? && coordinates[:latitude].present? && coordinates[:longitude].present?
    end

    # This method is wrapped in a `rescue` block to handle any exceptions
    # during the API call.
    # @return [Hash, nil] The coordinates response from the API, or nil in case of an error.
    def fetch_coordinates
      @client.geocode(@query)
    rescue StandardError => e
      capture_error(e)
      nil
    end

    # Captures any error that occurs during the location lookup process and logs it.
    # Additionally, it reports the error to Sentry for further monitoring and analysis.
    # @param error [StandardError] The error that occurred.
    def capture_error(error)
      message = "Location search failed for #{self.class} - #{query}, location search ignored (user experience unaffected)"

      logger.info(message)

      Sentry.capture_exception(
        error,
        message:,
      )
    end

    def blank_result
      CoordinatesResult.new(
        formatted_address: nil,
        latitude: nil,
        longitude: nil,
      )
    end

    def cache_key
      "geolocation:coordinates:v2:#{@query.parameterize}"
    end

    def log(message)
      Rails.logger.tagged(self.class.name) { @logger.info(message) }
    end
  end
end
