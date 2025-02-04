# frozen_string_literal: true

module Geolocation
  class LocationIdStrategy < LocationLookupStrategy
    def call
      @client.place_details(@location)
    end

    def cache_key
      "geolocation:location_id:#{@location}"
    end
  end
end
