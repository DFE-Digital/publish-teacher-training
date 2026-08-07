# frozen_string_literal: true

# A course that is allowed to publish without schools is served by the API with
# all of its provider's schools as locations, so writing a provider school
# changes that course's payload. Bumping `changed_at` is what tells API
# consumers to re-fetch it.
#
# Shaped like TouchProvider: the write itself is the trigger, so every writer
# gets this for free. Bulk writers that would otherwise repeat the sweep once
# per row wrap their loop in TouchSuppression.suppress and call
# `.touch_no_school_courses_for(provider)` once at the end instead.
module TouchNoSchoolCourses
  extend ActiveSupport::Concern

  included do
    after_save :touch_no_school_courses
    after_destroy :touch_no_school_courses
  end

  class_methods do
    def touch_no_school_courses_for(provider)
      # `changed_at` is UNIQUE, so every row needs its own timestamp.
      # update_columns skips the per-course provider touch — TouchProvider has
      # already bumped the provider once.
      Courses::PublishRules::SchoolPresenceExemption
        .falling_back_to_provider_schools(provider)
        .find_each { |course| course.update_columns(changed_at: Time.zone.now) }
    end
  end

private

  def touch_no_school_courses
    return if TouchSuppression.suppressed?

    self.class.touch_no_school_courses_for(provider)
  end
end
