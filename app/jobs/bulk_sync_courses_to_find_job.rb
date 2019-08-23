class BulkSyncCoursesToFindJob < ApplicationJob
  queue_as :find_sync

  def perform
    syncable_courses = []

    RecruitmentCycle.current_recruitment_cycle.providers
      .includes(:latest_published_enrichment)
      .each do |provider|
        if provider.publishable?
          syncable_courses.push(*provider.syncable_courses)
        end
      end

    if !syncable_courses.empty?
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
