class GeocodeSiteJob < ApplicationJob
  queue_as :geocoding

  def perform(site_id)
    site = Site.find(site_id)
    results = Geocoder.search(site.full_address)
    if results
      result = results.first
      site.update!(
        latitude: result.latitude,
        longitude: result.longitude
      )
    end
  end
end
