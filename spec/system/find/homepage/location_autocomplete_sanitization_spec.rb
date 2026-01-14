# frozen_string_literal: true

require "rails_helper"
require_relative "../results_helper"

RSpec.describe "Location autocomplete sanitization", :js, service: :find do
  include ResultsHelper

  let(:malicious_location) { "<h2><a href='test.com'>test.ca</a></h2>" }

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))

    stub_malicious_autocomplete_response
    when_i_visit_the_homepage
  end

  scenario "malicious HTML returned by the Places API is rendered as text" do
    fill_in "City, town or postcode", with: "Att"

    expect(page).to have_css("#location-field__listbox", visible: :visible)
    expect(page.find("#location-field__listbox")).to have_content(malicious_location)

    within("#location-field__listbox") do
      expect(page).to have_no_css("a", text: "test.ca")
      expect(page).to have_no_css("h2")
    end
  end

  def stub_malicious_autocomplete_response
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:uk&input=Att&key=replace_me&language=en&types=geocode",
    ).and_return(
      status: 200,
      body: file_fixture("google_old_places_api_client/autocomplete/malicious.json"),
      headers: { "Content-Type" => "application/json" },
    )
  end
end
