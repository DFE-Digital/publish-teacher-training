# frozen_string_literal: true

module DataHub
  module Geocoder
    class Base
      def geocode(record)
        raise NotImplementedError, "#{self.class} must implement #geocode"
      end

      def dry_run?
        false
      end
    end
  end
end
