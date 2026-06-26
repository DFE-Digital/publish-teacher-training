# frozen_string_literal: true

class CourseWizard
  class Draft
    class VisaDeadline
      attr_reader :date_parts

      def self.wrap(value)
        new(CourseWizard::Draft::DateParts.parse(value))
      end

      def initialize(date_parts)
        @date_parts = date_parts
      end

      delegate :blank?, to: :date_parts, allow_nil: true

      def date
        @date ||= date_parts&.to_date
      end

      def year
        date&.year
      end

      def month
        date&.month
      end

      def day
        date&.day
      end

      def to_formatted_string
        date&.to_fs(:govuk_date)
      end
    end
  end
end
