# frozen_string_literal: true

# Single source of truth for "is this course exempt from needing a school
# attached at publish time?". Support can approve individual salaried or
# apprenticeship courses to publish without schools (candidates already have
# their placement arranged) via the `publish_without_schools_allowed` flag.
#
# This is a support/business decision per course, so it is independent of the
# school data model. Never applies to fee-paying courses.
module Courses
  module PublishRules
    class SchoolPresenceExemption
      def self.applies?(course)
        course.publish_without_schools_allowed?
      end

      # The same rule over many courses at once: narrows the relation it is
      # given to the courses that must keep a school. It takes the relation
      # rather than being one, so there is nothing here to run - or read - as
      # a query over every course there is.
      def self.requiring_a_school(courses)
        courses.where(publish_without_schools_allowed: false)
      end

      # Courses whose API locations fall back to the provider's schools
      # (LocationsController#remodelled_locations) — so a provider school
      # write changes their payload.
      def self.falling_back_to_provider_schools(provider)
        provider.courses
                .where(publish_without_schools_allowed: true)
                .where.missing(:schools)
      end
    end
  end
end
