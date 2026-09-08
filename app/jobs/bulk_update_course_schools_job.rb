# frozen_string_literal: true

# Applies one placement school change across many courses.
#
# A bulk update writes both school relationships and their legacy site statuses
# for every course it matches, so even a modest provider is more work than a
# request should carry - the single-course write is already queued above thirty
# schools.
#
# A course that cannot be written does not hold up the rest, and is not dropped
# either: the job comes back for those alone, a few times, and says so once when
# it stops. Anything that escapes Apply entirely - a dropped connection, say -
# still bubbles, and Sidekiq retries the job as it would any other.
class BulkUpdateCourseSchoolsJob
  include Sidekiq::Job

  MAX_ATTEMPTS = 3
  RETRY_AFTER = 5.minutes

  def perform(course_ids, added_uuids, removed_uuids, attempt = 1)
    result = Publish::Schools::BulkUpdate::Apply.call(
      courses: Course.where(id: course_ids),
      added_uuids:,
      removed_uuids:,
    )

    return if result.failed_ids.empty?

    if attempt < MAX_ATTEMPTS
      self.class.perform_in(RETRY_AFTER, result.failed_ids, added_uuids, removed_uuids, attempt + 1)
    else
      report(result.failed_ids, added_uuids, removed_uuids, attempt)
    end
  end

private

  def report(course_ids, added_uuids, removed_uuids, attempt)
    Sentry.capture_message(
      "Bulk placement school update gave up on #{course_ids.size} courses",
      extra: { course_ids:, added_uuids:, removed_uuids:, attempts: attempt },
    )
  end
end
