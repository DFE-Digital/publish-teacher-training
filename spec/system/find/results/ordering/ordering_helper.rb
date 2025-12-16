# frozen_string_literal: true

module OrderingHelper
  def stub_london_location_search
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/geocode/json?address=London,%20UK&components=country:UK&key=replace_me&language=en",
    ).to_return(
      status: 200,
      body: file_fixture("google_old_places_api_client/geocode/london.json").read,
      headers: { "Content-Type" => "application/json" },
    )

    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/geocode/json?address=London&components=country:UK&key=replace_me&language=en",
    ).to_return(
      status: 200,
      body: file_fixture("google_old_places_api_client/geocode/london.json").read,
      headers: { "Content-Type" => "application/json" },
    )
  end

  def when_i_visit_the_find_results_page_with_london_location
    stub_london_location_search
    visit find_results_path(location: "London, UK")
  end

  def result_titles
    page.all(".govuk-summary-card__title", minimum: 1).map { |element| element.text.split("\n").join(" ") }
  end
end
