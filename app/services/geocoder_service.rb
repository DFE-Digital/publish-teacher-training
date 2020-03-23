class GeocoderService
  def self.geocode(obj:, force: false)
    return if obj.full_address.blank?

    result = Geokit::Geocoders::GoogleGeocoder.geocode(obj.full_address, bias: "gb")

    if result&.success == true
      obj.latitude = result.latitude
      obj.longitude = result.longitude

      region_code = COUNTY_TO_REGION_CODE[result.district]
      obj.region_code = region_code if region_code.present?

      obj.save!(validate: !force)
    end
  end
end
