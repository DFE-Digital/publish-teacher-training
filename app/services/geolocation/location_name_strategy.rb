# frozen_string_literal: true

module Geolocation
  class LocationNameStrategy < LocationLookupStrategy
    def fetch_coordinates
      @client.geocode(@location)
    rescue StandardError => e
      capture_error(e)
      nil
    end

    def cache_key
      "geolocation:location_name:#{@location}"
    end
  end
end
