# frozen_string_literal: true

module Geolocation
  class QueryStrategy < LocationLookupStrategy
    def initialize(query, logger: Rails.logger, cache: Rails.cache, client: GoogleOldPlacesAPI::Client.new, cache_expiration: 30.days)
      @query = query

      super
    end

    def call
      @client.geocode(@query)
    end

    def cache_key
      "geolocation:location_name:#{@query}"
    end
  end
end
