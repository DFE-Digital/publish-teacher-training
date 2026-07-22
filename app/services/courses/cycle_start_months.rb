# frozen_string_literal: true

module Courses
  # The months a course in a given recruitment cycle can start in: the whole
  # cycle year plus January to July of the next.
  #
  # Shared by the course wizard and the edit options (which offer the months
  # when setting a start date) and by the publish course list filter (which
  # offers them as checkboxes), so the three cannot drift apart.
  module CycleStartMonths
    MONTHS_INTO_FOLLOWING_YEAR = 7

    def self.for(year)
      cycle_year = year.to_i

      (1..12).map { |month| Date.new(cycle_year, month, 1) } +
        (1..MONTHS_INTO_FOLLOWING_YEAR).map { |month| Date.new(cycle_year + 1, month, 1) }
    end

    def self.labels_for(year)
      self.for(year).map { |month| "#{Date::MONTHNAMES[month.month]} #{month.year}" }
    end
  end
end
