# frozen_string_literal: true

# A course that is allowed to publish without schools is served by the API with
# all of its provider's schools as locations, so changing that provider's
# schools changes the course's payload. Bumping `changed_at` is what tells API
# consumers to re-fetch it.
module TouchNoSchoolCourses
  extend ActiveSupport::Concern

private

  def touch_all_no_school_courses
    # `changed_at` has a UNIQUE index, so every row needs its own timestamp.
    # update_columns skips the provider touch, which the provider school write
    # has already done.
    provider.courses.publishable_without_schools.find_each do |course|
      course.update_columns(changed_at: Time.zone.now)
    end
  end
end
