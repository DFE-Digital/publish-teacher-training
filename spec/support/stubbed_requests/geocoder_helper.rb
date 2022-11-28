module StubbedRequests
  module GeocoderHelper
    def stub_geocode
      Geocoder.configure(lookup: :test)

      Geocoder::Lookup::Test.set_default_stub(
        [
          {
            "coordinates" => [51.4524877, -0.1204749],
            "address" => "AA Teamworks W Yorks SCITT, School Street, Greetland, Halifax, West Yorkshire HX4 8JB",
            "state" => "England",
            "country" => "United Kingdom",
            "country_code" => "UK",
            "address_components" => [{ long_name: "England" }],
          },
        ],
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
            "address_components" => [{ long_name: "England" }],
          },
        ],
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
            "address_components" => [{ long_name: "England" }],
          },
        ],
      )

      Geocoder::Lookup::Test.add_stub(
        "Unknown location",
        [],
      )
    end
  end
end
