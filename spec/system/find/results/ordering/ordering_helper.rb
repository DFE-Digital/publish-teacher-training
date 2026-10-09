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
    # Read the provider name and course link only so status tags
    # (e.g. "Not accepting applications") do not affect ordering assertions.
    page.all(".course-summary-card", minimum: 1).map do |card|
      [
        card.find(".app-search-result__provider-name").text,
        card.find(".app-search-result__course-name").text,
      ].join(" ")
    end
  end
end
