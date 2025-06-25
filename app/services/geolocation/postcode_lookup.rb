module Geolocation
  class PostcodeLookup
    attr_reader :latitude, :longitude, :client

    def initialize(latitude:, longitude:, client: GoogleOldPlacesAPI::Client.new)
      @latitude = latitude
      @longitude = longitude
      @client = client
    end

    # Looks up the postcode based on latitude and longitude.
    # Returns a hash with the postcode and postcode area if found
    def call
      return nil if latitude.blank? || longitude.blank?

      result = client.reverse_geocode(latitude: latitude, longitude: longitude)
      return nil if result&.dig(:postcode).blank?

      postcode = result[:postcode]

      { postcode: postcode }
    end
  end
end
