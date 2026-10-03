# frozen_string_literal: true

module Courses
  # The buckets the Find start date filter offers, and the months each covers.
  #
  # Values are relative to the recruitment cycle rather than naming a year, so
  # bookmarked searches and email alerts keep meaning the same thing after
  # rollover. Together they span January of the cycle year to July of the next,
  # the same window as Courses::CycleStartMonths.
  module StartDateOptions
    # value => [first month, last month, years after the cycle year]
    BUCKETS = {
      "jan_to_mar" => [1, 3, 0],
      "apr_to_jun" => [4, 6, 0],
      "jul_to_aug" => [7, 8, 0],
      "september" => [9, 9, 0],
      "oct_to_dec" => [10, 12, 0],
      "next_jan_to_mar" => [1, 3, 1],
      "next_apr_to_jun" => [4, 6, 1],
      "next_jul" => [7, 7, 1],
    }.freeze

    ALL = BUCKETS.keys.freeze
    CURRENT_YEAR = BUCKETS.select { |_, (_, _, offset)| offset.zero? }.keys.freeze
    NEXT_YEAR = (ALL - CURRENT_YEAR).freeze

    # The broader buckets the filter used to offer, still found in old links,
    # recent searches and email alerts.
    LEGACY = {
      "jan_to_aug" => %w[jan_to_mar apr_to_jun jul_to_aug],
      "oct_to_jul" => %w[oct_to_dec next_jan_to_mar next_apr_to_jun next_jul],
    }.freeze

    def self.normalise(values)
      expanded = Array(values).flat_map { |value| LEGACY.fetch(value, value) }

      ALL & expanded
    end

    def self.ranges_for(values, year:)
      normalise(values).map do |value|
        first_month, last_month, offset = BUCKETS.fetch(value)

        Time.zone.local(year + offset, first_month, 1).beginning_of_month..
          Time.zone.local(year + offset, last_month, 1).end_of_month
      end
    end
  end
end
