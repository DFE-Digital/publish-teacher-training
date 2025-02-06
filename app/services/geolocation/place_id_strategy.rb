# frozen_string_literal: true

module Geolocation
  class PlaceIdStrategy < LocationLookupStrategy
    def initialize(place_id, logger: Rails.logger, cache: Rails.cache, client: GoogleOldPlacesAPI::Client.new, cache_expiration: 30.days)
      @place_id = place_id

      super
    end

    def call
      @client.place_details(@place_id)
    end

    def cache_key
      "geolocation:location_id:#{@place_id}"
    end
  end
end
