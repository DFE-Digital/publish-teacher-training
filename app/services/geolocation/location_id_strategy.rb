# frozen_string_literal: true

module Geolocation
  class LocationIdStrategy < LocationLookupStrategy
    def fetch_coordinates
      @client.place_details(@location)
    rescue StandardError => e
      capture_error(e)
      nil
    end

    def cache_key
      "geolocation:location_id:#{@location}"
    end
  end
end
