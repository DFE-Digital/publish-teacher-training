class GeocodeJob < ApplicationJob
  queue_as :geocoding

  def perform(klass, id)
    record = klass.classify.safe_constantize.find(id)
    GeocoderService.geocode(obj: record) if record
  end
end
