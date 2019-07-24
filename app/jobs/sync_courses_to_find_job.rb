class SyncCoursesToFindJob < ApplicationJob
  queue_as :find_sync

  def perform(*courses)
    SearchAndCompareAPIService::Request.sync(courses)
  end
end
