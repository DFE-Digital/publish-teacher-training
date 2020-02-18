class GeocoderService
  def self.geocode(obj:, force: false)
    result = Geokit::Geocoders::MultiGeocoder.geocode(obj.full_address, params: { region: "gb" })

    #binding.pry
    if result.present?
      obj.latitude = result.lat
      obj.longitude = result.lng
      obj.save!(validate: !force)
    end
  end
end
