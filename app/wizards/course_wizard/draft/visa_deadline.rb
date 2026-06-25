# frozen_string_literal: true

class CourseWizard
  class Draft
    class VisaDeadline
      attr_reader :value

      def initialize(value)
        @value = value
      end

      delegate :blank?, to: :value

      def date
        @date ||= parse_date
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

    private

      def parse_date
        return value.to_date if value.respond_to?(:to_date)
        return Date.new(value.year.to_i, value.month.to_i, value.day.to_i) if date_parts?(value)
        return parse_hash(value) if value.is_a?(Hash)

        nil
      rescue Date::Error
        nil
      end

      def date_parts?(candidate)
        candidate.is_a?(CourseWizard::Steps::VisaSponsorshipApplicationDeadlineAt::DateParts)
      end

      def parse_hash(hash)
        year = hash[:year] || hash["year"]
        month = hash[:month] || hash["month"]
        day = hash[:day] || hash["day"]
        return if [year, month, day].any?(&:blank?)

        Date.new(year.to_i, month.to_i, day.to_i)
      end
    end
  end
end
