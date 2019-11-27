class GeocodeJob < ApplicationJob
  queue_as :geocoding

  def perform(klass, id)
    record = klass.classify.safe_constantize.find(id)
    results = Geocoder.search(record.full_address)
    if results
      result = results.first
      record.update!(
        latitude: result.latitude,
        longitude: result.longitude,
      )
    end
  end
end
