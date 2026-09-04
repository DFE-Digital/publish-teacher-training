# frozen_string_literal: true

# Applies one placement school change across many courses.
#
# A bulk update writes both school relationships and their legacy site statuses
# for every course it matches, so even a modest provider is more work than a
# request should carry - the single-course write is already queued above thirty
# schools.
class BulkUpdateCourseSchoolsJob
  include Sidekiq::Job

  def perform(course_ids, added_uuids, removed_uuids)
    Publish::Schools::BulkUpdate::Apply.call(
      courses: Course.where(id: course_ids),
      added_uuids:,
      removed_uuids:,
    )
  end
end
