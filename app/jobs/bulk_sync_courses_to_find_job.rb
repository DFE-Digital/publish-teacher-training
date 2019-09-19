class BulkSyncCoursesToFindJob < ApplicationJob
  queue_as :find_sync

  def perform
    syncable_courses = RecruitmentCycle.syncable_courses

    if syncable_courses.present?
      request = SearchAndCompareAPIService::Request.new

      unless request.bulk_sync(syncable_courses)
        raise(RuntimeError.new(
                "Error #{request.response.status} received syncing courses: " \
                + courses.join('; ')
              ))
      end
    end
  end
end
