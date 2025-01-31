# frozen_string_literal: true

module Find
  module GooglePlacesAPI
    class AutoComplete
      Result = Struct.new(:name, :place_id, :latitude, :longitude, :location_types, keyword_init: true)

      def self.call(query:)
        new.call(query)
      end

      def initialize(client = Client.new)
        @client = client
      end

      def call(query)
        response = @client.autocomplete(query:)

        return [] unless response[:suggestions]

        response[:suggestions].map do |suggestion|
          place = suggestion[:placePrediction]

          Result.new(
            name: place.dig(:structuredFormat, :mainText, :text),
            place_id: place[:placeId],
            latitude: place.dig(:geometry, :location, :lat),
            longitude: place.dig(:geometry, :location, :lng),
            location_types: place[:types]
          )
        end
      end
    end
  end
end
