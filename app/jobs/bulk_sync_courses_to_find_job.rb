class BulkSyncCoursesToFindJob < ApplicationJob
  queue_as :find_sync

  class SearchAndCompareRequestError < StandardError
  end

  def perform
    syncable_courses = RecruitmentCycle.syncable_courses

    if syncable_courses.present?
      request = SearchAndCompareAPIService::Request.new

      unless request.bulk_sync(syncable_courses)
        if request.response.status == 502
          # Make sure we don't trigger retries for 502, which we get because
          # the request sac api takes too long for the lb that fronts it, and
          # it's timeout cannot be changed.
          Rails.logger.error "Error 502 received syncing courses: " \
                             + syncable_courses.join("; ")
        else
          raise(
            SearchAndCompareRequestError.new(
              "Error #{request.response.status} received syncing courses: #{syncable_courses.join('; ')}",
            ),
          )
        end
      end
    end
  end
end
