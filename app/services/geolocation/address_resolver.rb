# frozen_string_literal: true

module Geolocation
  # Geocode a location query into normalized coordinates.
  #
  # Handles caching of geocoding results and wraps the response in a
  # hash object. Normalizes provider-specific API responses
  # into a common hash format, ensuring location service agnosticism.
  #
  # @example
  #   query = Geolocation::AddressResolver.new("London")
  #   result = query.call
  #   # => { latitude: '' ... }
  #
  # @attr_reader query [String] The location query string
  # @attr_reader logger [Logger] Logger instance for debug/info output
  # @attr_reader cache [ActiveSupport::Cache::Store] Cache store for results
  # @attr_reader client [GoogleOldPlacesAPI::Client] Geocoding API client
  # @attr_reader cache_expiration [ActiveSupport::Duration] Cache TTL
  class AddressResolver
    attr_reader :query, :logger, :cache, :client, :cache_expiration

    # Initialize a new geocoding query.
    #
    # @param query [String] The location to geocode
    # @param logger [Logger] Rails logger
    # @param cache [ActiveSupport::Cache::Store] Cache store
    # @param client [#geocode] Geocoding API client
    # @param cache_expiration [ActiveSupport::Duration] Cache TTL
    def initialize(query, logger:, cache:, client:, cache_expiration:)
      @query = query
      @logger = logger
      @cache = cache
      @client = client
      @cache_expiration = cache_expiration
    end

    # Geocode the query with caching.
    #
    # @return [Hash] Client results wrapped in hash object
    def call
      return blank_result if query.blank?

      cached_data || fetch_and_cache
    end

    def cached_data
      cache.read(cache_key).tap do |cached_data|
        if cached_data
          log("Cache HIT for: '#{query}' | Key: #{cache_key} | Cached: #{cached_data.inspect}")
        else
          log("Cache MISS for: '#{query}' | Key: #{cache_key}")
        end
      end
    end

    def fetch_and_cache
      data = fetch_coordinates
      return blank_result unless valid_address?(data)

      cache.write(cache_key, data, expires_in: @cache_expiration)

      data
    end

    def valid_address?(data)
      data.present? && data[:latitude].present? && data[:longitude].present?
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
      {
        latitude: nil,
        longitude: nil,
        formatted_address: nil,
        country: nil,
        address_types: [],
      }
    end

    def cache_key
      "geolocation:address_resolver:#{@query.parameterize}"
    end

    def log(message)
      Rails.logger.tagged(self.class.name) { @logger.info(message) }
    end
  end
end
