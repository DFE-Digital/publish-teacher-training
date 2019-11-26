module Helpers
  def stub_geocoder
    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          "coordinates" => [51.4524877, -0.1204749],
          "address" => "AA Teamworks W Yorks SCITT, School Street, Greetland, Halifax, West Yorkshire,  HX4 8JB",
          "state" => "England",
          "country" => "United Kingdom",
          "country_code" => "gb",
        },
      ],
    )

    Geocoder::Lookup::Test.add_stub(
      "Long Lane, Holbury, Southampton, SO45 2PA",
      [
        {
          "coordinates" => [50.8312522, -1.3792036],
          "address" => "Long Lane, Holbury, Southampton, SO45 2PA",
          "state" => "England",
          "country" => "United Kingdom",
          "country_code" => "gb",
        },
      ],
    )

    Geocoder::Lookup::Test.add_stub(
      "Academies Enterprise Trust: Aylward Academy, Windmill Road, London, N18 1NB",
      [
        {
          "coordinates" => [51.4524877, -0.1204749],
          "address" => "Academies Enterprise Trust: Aylward Academy, Windmill Road, London, N18 1NB",
          "state" => "London",
          "state_code" => "London",
          "country" => "United Kingdom",
          "country_code" => "UK",
        },
      ],
    )
  end
end
