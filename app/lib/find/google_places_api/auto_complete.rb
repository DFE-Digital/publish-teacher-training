# frozen_string_literal: true

module Find
  module GooglePlacesAPI
    class AutoComplete
      Result = Struct.new(:name, :place_id, :latitude, :longitude, :location_types, keyword_init: true)

      def self.call(query:)
        new.call(query)
      end

      def initialize
        @client = case Settings.find_search_api_name
        when 'places_api_new'
          NewPlacesClient.new
        else
          OldPlacesClient.new
        end
      end

      def call(query)
        @client.autocomplete(query:)
      end
    end
  end
end
