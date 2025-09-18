# frozen_string_literal: true

# DataHub namespace which stores import logs and summaries
module DataHub
  # Namespace for course naming change functionality
  module CourseNamingChange
    # Value object encapsulating the outcome of processing a single CSV row.
    class RowResult
      attr_reader :line_number,
                  :course_name,
                  :replacement_name,
                  :expected_count,
                  :actual_count,
                  :course_identifiers,
                  :warning_reason

      # @param line_number [Integer]
      # @param course_name [String]
      # @param replacement_name [String]
      # @param expected_count [Integer, nil]
      # @param actual_count [Integer]
      # @param course_identifiers [Array<String>]
      # @param warning [Boolean]
      # @param warning_reason [String, nil]
      def initialize(line_number:, course_name:, replacement_name:, expected_count:, actual_count:, course_identifiers:, warning:, warning_reason: nil)
        @line_number = line_number
        @course_name = course_name
        @replacement_name = replacement_name
        @expected_count = expected_count
        @actual_count = actual_count
        @course_identifiers = course_identifiers
        @warning = warning
        @warning_reason = warning_reason
      end

      # @return [Boolean]
      def warning?
        @warning
      end

      # Difference between actual and expected counts or nil when no expectation
      # was provided.
      #
      # @return [Integer, nil]
      def difference
        return nil if expected_count.nil?

        actual_count - expected_count
      end

      def to_h
        {
          "line_number" => line_number,
          "course_name" => course_name,
          "replacement_name" => replacement_name,
          "expected_count" => expected_count,
          "actual_count" => actual_count,
          "difference" => difference,
          "warning" => warning?,
          "warning_reason" => warning_reason,
          "course_identifiers" => course_identifiers,
        }
      end
    end
  end
end
