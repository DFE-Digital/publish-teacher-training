# frozen_string_literal: true

module Geolocation
  class LocationNameStrategy < LocationLookupStrategy
    def call
      @client.geocode(@location)
    end

    def cache_key
      "geolocation:location_name:#{@location}"
    end
  end
end
