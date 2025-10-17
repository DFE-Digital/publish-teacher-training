# frozen_string_literal: true

module DataHub
  module BlankCoordinatesBackfill
    class Log
      TAG = "BlankCoordinatesBackfill"

      def self.with_logging(&block)
        Rails.logger.tagged(TAG, &block)
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
