class TravelToWorkAreaAndLondonBoroughJob < ApplicationJob
  queue_as :add_travel_to_work_area_and_london_borough

  def perform(klass, id)
    RequestStore.store[:job_id] = provider_job_id
    RequestStore.store[:job_queue] = queue_name

    record = klass.classify.safe_constantize.find(id)
    TravelToWorkAreaAndLondonBoroughService.add_travel_to_work_area_and_london_borough(site: record) if record
  end
end
