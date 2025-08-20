module DataHub
  module Rollover
    class RolloverLog
      TAG = "Rollover".freeze

      def self.with_logging
        Rails.logger.tagged(TAG) { yield }
      end

      def self.info(message)
        with_logging { Rails.logger.info(message) }
      end

      def self.warn(message)
        with_logging { Rails.logger.warn(message) }
      end

      def self.error(message)
        with_logging { Rails.logger.error(message) }
      end
    end
  end
end
