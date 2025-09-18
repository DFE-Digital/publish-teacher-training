# frozen_string_literal: true

# DataHub namespace which stores import logs and summaries
module DataHub
  # Namespace for course naming change functionality
  module CourseNamingChange
    # Aggregated statistics for an entire CSV import.
    class Report
      attr_reader :rows, :dry_run

      # @param rows [Array<DataHub::CourseNamingChange::RowResult>]
      # @param dry_run [Boolean]
      def initialize(rows:, dry_run:)
        @rows = rows
        @dry_run = dry_run
      end

      # @return [Integer]
      def total_expected
        rows.sum { |row| row.expected_count.to_i }
      end

      # @return [Integer]
      def total_actual
        rows.sum(&:actual_count)
      end

      # @return [Integer]
      def total_difference
        total_actual - total_expected
      end

      # @return [Array<DataHub::CourseNamingChange::RowResult>]
      def flagged_rows
        rows.select(&:warning?)
      end

      # @return [Integer]
      def warnings_count
        flagged_rows.size
      end

      # @return [Integer]
      def processed_rows
        rows.size
      end

      # @return [Boolean]
      def dry_run?
        dry_run
      end
    end
  end
end
