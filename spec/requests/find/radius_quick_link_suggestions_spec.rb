# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::RadiusQuickLinkSuggestions", type: :request do
  describe "GET /api/radius_quick_link_suggestions" do
    let(:search_params) do
      {
        subject_name: "Mathematics",
        subject_code: "G1",
        latitude: 51.5074,
        longitude: -0.1278,
        radius: 1,
      }
    end

    context "with 3 courses in separate radius buckets" do
      before do
        subject_record = find_or_create(:secondary_subject, :mathematics)

        [
          [51.4550, -0.9711],
          [52.5769, -0.2424],
          [52.4862, -1.8904],
        ].each do |latitude, longitude|
          course = create(:course, :secondary, :published, subjects: [subject_record])
          create(:course_school, course:, gias_school: create(:gias_school, latitude:, longitude:))
        end
      end

      it "returns quick link suggestions for 50 and 100 mile buckets" do
        get "/api/radius_quick_link_suggestions", params: search_params

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json.map { |l| l["text"] }).to include(
          a_string_matching(/^50 miles \(1 course\)/i),
          a_string_matching(/^100 miles \(2 courses\)/i),
        )
      end
    end

    context "with 3 courses in separate radius buckets, checking the links" do
      before do
        subject_record = find_or_create(:secondary_subject, :mathematics)

        course = create(:course, :secondary, :published, subjects: [subject_record])
        create(:course_school, course:, gias_school: create(:gias_school, latitude: 51.4550, longitude: -0.9711))
      end

      it "routes each suggestion through track_click, naming the radius" do
        get "/api/radius_quick_link_suggestions", params: search_params

        JSON.parse(response.body).each do |link|
          uri = URI(link["url"])
          query = Rack::Utils.parse_query(uri.query)

          expect(uri.path).to eq("/track_click")
          expect(query["utm_content"]).to match(/\Ano_results_radius_quick_link_\d+_miles\z/)
          expect(query["url"]).to start_with("/results?")
        end
      end

      # The destination is built from the visitor's own query string, and it is
      # now the url a redirect acts on, so it must not be able to leave the site.
      it "cannot be pushed off site by url_for options in the query string" do
        get "/api/radius_quick_link_suggestions", params: search_params.merge(
          host: "evil.com",
          protocol: "https",
          script_name: "//evil.com",
        )

        links = JSON.parse(response.body)
        expect(links).not_to be_empty

        links.each do |link|
          expect(link["url"]).to start_with("/track_click?")
          expect(Rack::Utils.parse_query(URI(link["url"]).query)["url"]).to start_with("/results?")
        end
      end
    end

    context "when a bucket has over 100 results" do
      before do
        101.times do
          course = create(:course, :secondary, :published, subjects: [find_or_create(:secondary_subject, :mathematics)])
          create(:course_school, course:, gias_school: create(:gias_school, latitude: 51.5074, longitude: -0.1278))
        end
      end

      it "returns a single suggestion with 100+ courses text" do
        get "/api/radius_quick_link_suggestions", params: search_params

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json.first["text"]).to match(/^10 miles \(more than 100 courses\)/i)
      end
    end
  end
end
