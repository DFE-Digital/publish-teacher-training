module GeocoderHelper
  class GeocoderStub
    def geocode(address, **_params)
      case address
      when "Fun Academy, Long Lane, Holbury, Southampton, UK, SO45 2PA"
        Geokit::GeoLoc.new(
          lat: 50.8312522,
          lng: -1.3792036,
          full_address: "Long Lane, Holbury, Southampton, UK, SO45 2PA",
          zip: "SO45 2PA",
          state: "England",
          state_code: "England",
          country: "United Kingdom",
          country_code: "gb",
        ).tap do |loc|
          loc.district = "Hampshire"
          loc.success = true
        end
      # Some legacy sites and providers have no address whatsoever
      when nil
        Geokit::GeoLoc.new.tap do |loc|
          loc.success = false
        end
      else
        Geokit::GeoLoc.new(
          lat: 51.4524877,
          lng: -0.1204749,
          full_address: "Academies Enterprise Trust: Aylward Academy, Windmill Road, London, N18 1NB",
          zip: "N18 1NB",
          state: "London",
          state_code: "England",
          country: "United Kingdom",
          country_code: "UK",
          success: true,
        ).tap do |loc|
          loc.district = "Greater London"
          loc.success = true
        end
      end
    end
  end
end
