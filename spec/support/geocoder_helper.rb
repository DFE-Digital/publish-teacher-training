# frozen_string_literal: true

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
          country_code: "gb"
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
          success: true
        ).tap do |loc|
          loc.district = "Greater London"
          loc.success = true
        end
      end
    end
  end

  def stub_geocoder_lookup
    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          "coordinates" => [51.4524877, -0.1204749],
          "address" => "AA Teamworks W Yorks SCITT, School Street, Greetland, Halifax, West Yorkshire HX4 8JB",
          "state" => "England",
          "country" => "United Kingdom",
          "country_code" => "UK",
          "address_components" => [{ long_name: "England" }]
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "SW1P 3BT",
      [
        {
          "coordinates" => [51.4980188, -0.1300436],
          "address" => "Westminster, London SW1P 3BT, UK",
          "state" => "England",
          "state_code" => "England",
          "country" => "United Kingdom",
          "country_code" => "UK",
          "address_components" => [{ long_name: "England" }]
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "Station Rise",
      [
        {
          "coordinates" => [53.83365879999999, -1.0564076],
          "address" => "Station Rise, Ricall, York YO19 2C, UK",
          "state" => "England",
          "state_code" => "England",
          "country" => "United Kingdom",
          "country_code" => "UK",
          "address_components" => [{ long_name: "England" }]
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "Unknown location",
      []
    )
  end
end
