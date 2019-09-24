class SyncCoursesToFindJob < ApplicationJob
  queue_as :find_sync

  def perform(*courses)
    request = SearchAndCompareAPIService::Request.new
    unless request.sync(courses)
      raise(RuntimeError.new(
              "Error #{request.response.status} received syncing courses: " \
              + courses.join("; "),
            ))
    end
  end
end
