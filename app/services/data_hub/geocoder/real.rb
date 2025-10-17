module DataHub
  module Geocoder
    class Real < Base
      def geocode(record)
        GeocoderService.geocode(obj: record)
        record.reload

        if record.latitude.present? && record.longitude.present?
          Result.new(
            success: true,
            latitude: record.latitude,
            longitude: record.longitude,
          )
        else
          Result.new(
            success: false,
            latitude: nil,
            longitude: nil,
            error_message: "Geocoding failed - no coordinates returned",
          )
        end
      rescue StandardError => e
        Result.new(
          success: false,
          latitude: nil,
          longitude: nil,
          error_message: "#{e.class}: #{e.message}",
        )
      end

      def dry_run?
        false
      end
    end
  end
end
