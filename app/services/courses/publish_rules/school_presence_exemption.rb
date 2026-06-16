# frozen_string_literal: true

# Single source of truth for "is this course exempt from needing a school
# attached at publish time?". Support can approve individual salaried or
# apprenticeship courses to publish without schools (candidates already have
# their placement arranged) via the `publish_without_schools_allowed` flag.
#
# Only applies under the new Course::School data model (the
# :course_publishing_uses_new_school_model flag), mirroring
# Courses::PublishRules::SchoolPresence so the flag lives in one place. Never
# applies to fee-paying courses or to legacy Site data.
module Courses
  module PublishRules
    class SchoolPresenceExemption
      def self.applies?(course)
        FeatureFlag.active?(:course_publishing_uses_new_school_model) &&
          course.publish_without_schools_allowed? &&
          (course.salary? || course.apprenticeship?)
      end
    end
  end
end
