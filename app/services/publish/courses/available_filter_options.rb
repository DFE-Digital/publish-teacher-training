# frozen_string_literal: true

module Publish
  module Courses
    # The status, education phase and funding values a provider's courses
    # actually have, for those filters on the publish course list. Offering the
    # whole fixed list instead would fill the panel with options that narrow
    # the list to nothing.
    #
    # Read from +Publish::Courses::Query+, the same rows the list renders, so a
    # status is the token the provider sees (Open, Closed, Scheduled) rather
    # than the raw enrichment status.
    module AvailableFilterOptions
      def self.for(provider)
        courses = Query.call(provider:).to_a

        {
          status: courses.map { |course| StatusTag.token(course).to_s },
          level: courses.map(&:level),
          funding: courses.map(&:funding),
        }.transform_values { |values| values.compact.uniq }
      end
    end
  end
end
