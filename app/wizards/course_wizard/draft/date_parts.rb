# frozen_string_literal: true

class CourseWizard
  class Draft
    DateParts = Struct.new(:year, :month, :day) do
      def self.parse(value)
        return if value.blank?
        return value if value.is_a?(self)
        return from_date_like(value) if value.respond_to?(:to_date)
        return from_hash(value) if value.is_a?(Hash)

        nil
      rescue Date::Error
        nil
      end

      def self.from_hash(value)
        new(value[:year] || value["year"], value[:month] || value["month"], value[:day] || value["day"])
      end

      def self.from_date_like(value)
        date = value.to_date
        new(date.year.to_s, date.month.to_s, date.day.to_s)
      end

      def blank?
        [year, month, day].all?(&:blank?)
      end

      def to_date
        return if [year, month, day].any?(&:blank?)

        Date.new(year.to_i, month.to_i, day.to_i)
      rescue Date::Error
        nil
      end
    end
  end
end
