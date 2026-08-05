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
        course.publish_without_schools_allowed? &&
          (course.salary? || course.apprenticeship?)
      end
    end
  end
end
