class GeocoderService
  def self.geocode(obj:, force: false)
    results = Geocoder.search(obj.full_address, params: { region: "gb" })

    if results.present?
      result = results.first
      obj.latitude = result.latitude
      obj.longitude = result.longitude
      obj.save(validate: !force)
    end
  end
end
