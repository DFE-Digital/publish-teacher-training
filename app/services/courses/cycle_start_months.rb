# frozen_string_literal: true

module Courses
  # The months a course in a given recruitment cycle can start in: the whole
  # cycle year plus January to July of the next.
  #
  # Shared by the course wizard and the edit options, which both offer these
  # months when setting a start date, so the two cannot drift apart. The publish
  # course list filter offers the months its courses actually start in instead —
  # see Publish::Courses::AvailableStartMonths.
  module CycleStartMonths
    MONTHS_INTO_FOLLOWING_YEAR = 7

    def self.for(year)
      cycle_year = year.to_i

      (1..12).map { |month| Date.new(cycle_year, month, 1) } +
        (1..MONTHS_INTO_FOLLOWING_YEAR).map { |month| Date.new(cycle_year + 1, month, 1) }
    end

    def self.labels_for(year)
      self.for(year).map { |month| label_for(month) }
    end

    # The months a course could still start in, for a course that has not picked
    # a start date yet. A month stays on offer until it ends, so a course can
    # still be set to start later in the current month.
    #
    # Compares dates rather than slicing the list at a month name, so the rule
    # holds wherever today sits relative to the cycle. A cycle runs from the
    # September before its year to the July after it, so all three cases occur:
    # before the cycle's months begin, during them, and after the cycle has been
    # superseded but while its later months are still ahead.
    #
    # Falls back to every month once they have all passed, so a cycle that is
    # entirely in the past offers its real months rather than nothing at all.
    def self.remaining_labels_for(year, today = Time.zone.today)
      months = self.for(year)
      remaining = months.select { |month| month >= today.beginning_of_month }

      (remaining.presence || months).map { |month| label_for(month) }
    end

    def self.label_for(month)
      "#{Date::MONTHNAMES[month.month]} #{month.year}"
    end
  end
end
