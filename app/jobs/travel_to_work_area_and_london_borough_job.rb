class TravelToWorkAreaAndLondonBoroughJob < ApplicationJob
  queue_as :add_travel_to_work_area_and_london_borough

  def perform(id)
    RequestStore.store[:job_id] = provider_job_id
    RequestStore.store[:job_queue] = queue_name

    site = Site.find_by(id: id)
    TravelToWorkAreaAndLondonBoroughService.call(site: site) if site
  end
end
