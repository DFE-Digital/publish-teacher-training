module DataHub
  module Geocoder
    class DryRun < Base
      def geocode(_record)
        # Simulate API delay (Google is ~20-50ms)
        sleep(0.02) if Rails.env.development?

        # Simulate 95% success rate
        if rand < 0.95
          Result.new(
            success: true,
            latitude: simulate_uk_latitude,
            longitude: simulate_uk_longitude,
          )
        else
          Result.new(
            success: false,
            latitude: nil,
            longitude: nil,
            error_message: "Simulated geocoding failure",
          )
        end
      end

      def dry_run?
        true
      end

    private

      def simulate_uk_latitude
        # UK latitude range: 49.9 to 60.8
        rand(49.9..60.8).round(6)
      end

      def simulate_uk_longitude
        # UK longitude range: -8.6 to 1.8
        rand(-8.6..1.8).round(6)
      end
    end
  end
end
