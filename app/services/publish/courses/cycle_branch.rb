# frozen_string_literal: true

module Publish
  module Courses
    # Which status vocabulary a recruitment cycle year uses. Courses in the
    # current or previous cycle are Open/Closed depending on their application
    # status; courses in a future cycle are Scheduled instead.
    #
    # Shared by StatusTagComponent (which renders the tag) and Query (which
    # filters on it) so the two cannot disagree about what a status means.
    module CycleBranch
      def self.current_or_previous?(year)
        [Find::CycleTimetable.current_year, Find::CycleTimetable.previous_year].include?(year.to_i)
      end
    end
  end
end
