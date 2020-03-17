class GeocodeJob < ApplicationJob
  queue_as :geocoding

  def perform(klass, id)
    RequestStore.store[:job_id] = provider_job_id
    RequestStore.store[:job_queue] = queue_name

    record = klass.classify.safe_constantize.find(id)
    GeocoderService.geocode(obj: record) if record
  end
end
