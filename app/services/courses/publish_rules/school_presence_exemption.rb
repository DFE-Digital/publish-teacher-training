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
      EXEMPT_FUNDINGS = %w[salary apprenticeship].freeze

      def self.applies?(course)
        course.publish_without_schools_allowed? &&
          EXEMPT_FUNDINGS.include?(course.funding)
      end

      # Courses whose API locations fall back to the provider's schools
      # (LocationsController#remodelled_locations) — so a provider school
      # write changes their payload.
      def self.falling_back_to_provider_schools(provider)
        provider.courses
                .where(publish_without_schools_allowed: true, funding: EXEMPT_FUNDINGS)
                .where.missing(:schools)
      end
    end
  end
end
