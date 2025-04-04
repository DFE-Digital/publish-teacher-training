# frozen_string_literal: true

module Geolocation
  # Query Google autocomplete API with a text query to get GooglePlaces API response json
  #
  # @see GoogleOldPlacesAPI::Client
  class Suggestions
    def initialize(query, cache: Rails.cache, cache_expiration: 30.days, logger: Rails.logger, client: GoogleOldPlacesAPI::Client.new)
      @query = query
      @cache = cache
      @logger = logger
      @client = client
      @cache_expiration = cache_expiration
    end

    def call
      return [] if @query.blank?

      cached_suggestions || fetch_suggestions_and_cache
    end

    def cached_suggestions
      @cache.read(cache_key).tap do |cached_data|
        if cached_data
          @logger.info("CACHE HIT suggestion for: #{@query}")
        else
          @logger.info("CACHE MISS suggestion for: #{@query}")
        end
      end
    end

    def cache_key
      "geolocation:suggestions:#{@query.parameterize}"
    end

    def fetch_suggestions_and_cache
      suggestions = fetch_suggestions
      return [] if suggestions.blank?

      cache_suggestions(suggestions)

      suggestions
    end

    def cache_suggestions(response)
      @cache.write(cache_key, response, expires_in: @cache_expiration)
    end

    def fetch_suggestions
      @client.autocomplete(@query)
    rescue StandardError => e
      capture_error(e)
      nil
    end

    def capture_error(error)
      message = "Location suggestion failed for #{self.class} - #{@query}, suggestions ignored (user experience unaffected)"

      @logger.info(message)

      Sentry.capture_exception(error, message:)
    end
  end
end
