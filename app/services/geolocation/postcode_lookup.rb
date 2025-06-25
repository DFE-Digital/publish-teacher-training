module Geolocation
  class PostcodeLookup
    attr_reader :latitude, :longitude, :client

    def initialize(latitude:, longitude:, client: GoogleOldPlacesAPI::Client.new)
      @latitude = latitude
      @longitude = longitude
      @client = client
    end

    # Looks up the postcode area based on latitude and longitude.
    def call
      return nil if latitude.blank? || longitude.blank?

      result = client.reverse_geocode(latitude: latitude, longitude: longitude)
      return nil if result&.dig(:postcode).blank?

      postcode_area = result[:postcode].split(" ").first

      { postcode: postcode_area }
    end
  end
end
