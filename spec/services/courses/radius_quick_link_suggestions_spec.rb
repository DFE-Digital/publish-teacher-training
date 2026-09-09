# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::RadiusQuickLinkSuggestions do
  include Rails.application.routes.url_helpers

  subject(:suggestions) do
    described_class.new(
      params: { subject_name: "Mathematics" },
      i18n_scope: "api.radius_quick_link_suggestions",
      request_query: { "subject_name" => "Mathematics" },
      query_service:,
    ).call
  end

  let(:query_service) { class_double(Courses::Query, call: relation) }
  let(:relation) { instance_double(ActiveRecord::Relation, limit: courses) }

  # minimum_distance_to_search_location is selected by the query rather than
  # declared on Course, so stand in for it with a struct.
  let(:searched_course) { Struct.new(:minimum_distance_to_search_location) }

  # One course 30 miles away and one 80 miles away, so the 50 and 100 mile
  # buckets are the ones with results.
  let(:courses) { [searched_course.new(30), searched_course.new(80)] }

  it "suggests a link for each radius that has courses" do
    expect(suggestions.map { |link| link[:text] }).to eq(
      ["50 miles (1 course)", "100 miles (2 courses)"],
    )
  end

  it "routes every link through track_click" do
    expect(suggestions.map { |link| URI(link[:url]).path }).to all(eq("/track_click"))
  end

  it "names the radius in the utm_content so each link can be told apart" do
    utm_contents = suggestions.map { |link| Rack::Utils.parse_query(URI(link[:url]).query)["utm_content"] }

    expect(utm_contents).to eq(
      %w[no_results_radius_quick_link_50_miles no_results_radius_quick_link_100_miles],
    )
  end

  it "keeps the widened search as the tracked destination" do
    destinations = suggestions.map { |link| Rack::Utils.parse_query(URI(link[:url]).query)["url"] }

    expect(destinations).to eq(
      [
        find_results_path(subject_name: "Mathematics", radius: 50),
        find_results_path(subject_name: "Mathematics", radius: 100),
      ],
    )
  end
end
