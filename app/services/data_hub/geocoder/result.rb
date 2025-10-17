module DataHub
  module Geocoder
    # Result struct returned by all geocoders
    Result = Struct.new(:success, :latitude, :longitude, :error_message, keyword_init: true) do
      def success?
        success.present?
      end

      def failed?
        !success?
      end
    end
  end
end
