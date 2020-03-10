class SyncCoursesToFindJob < ApplicationJob
  queue_as :find_sync

  def perform(*courses)
    RequestStore.store[:job_id] = provider_job_id
    RequestStore.store[:job_queue] = queue_name

    request = SearchAndCompareAPIService::Request.new
    unless request.sync(courses)
      raise(
        RuntimeError.new(
          "Error #{request.response.status} received syncing courses: #{courses.join('; ')}",
        ),
      )
    end
  end
end
