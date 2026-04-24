# frozen_string_literal: true

# Single source of truth for "does this course have any school attached,
# for the purposes of the :publish validation context?". Flips between
# legacy Site-based reads and the new Course::School reads based on the
# :course_publishing_uses_new_school_model flag. Every publish-side
# school check funnels through here so the flag lives in exactly one place.
module Courses
  module PublishRules
    class SchoolPresence
      def self.any?(course)
        if FeatureFlag.active?(:course_publishing_uses_new_school_model)
          course.schools.any?
        else
          # Use Enumerable#any? with a block rather than chaining `.school`
          # (a scope) so this works on unpersisted courses too — the
          # presence check runs on the :new validation context where the
          # course isn't saved yet and its sites are only in memory.
          course.sites.any?(&:school?)
        end
      end
    end
  end
end
