class GeocoderService
  def self.geocode(obj:, force: false)
    result = Geokit::Geocoders::GoogleGeocoder.geocode(obj.full_address, bias: "gb")

    if result.present?
      obj.latitude = result.latitude
      obj.longitude = result.longitude
      obj.save!(validate: !force)
    end
  end
end
