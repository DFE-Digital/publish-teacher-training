# frozen_string_literal: true

module Publish
  module Courses
    # The months a provider's courses actually start in, for the start date
    # filter on the publish course list. Offering the whole cycle window instead
    # would fill the panel with months that narrow the list to nothing.
    #
    # Read from +Provider#courses+, the same base scope +Publish::Courses::Query+
    # builds the list from, so an offered month always matches at least one
    # course and a listed course's month is always offered.
    module AvailableStartMonths
      # The month is resolved in the application's zone, never in UTC: a course
      # starting 2026-09-01 00:30 is stored as 2026-08-31 23:30 UTC, but the list
      # displays it under September and Query matches it under September, so a
      # UTC month would offer an August option that finds nothing.
      #
      # Dates rather than times, because the checkbox label comes from
      # I18n.l(month, format: :short), which formats the two quite differently.
      def self.for(provider)
        provider.courses.distinct.pluck(:start_date).compact.map { |start_date|
          start_date.in_time_zone.to_date.beginning_of_month
        }.uniq.sort
      end
    end
  end
end
