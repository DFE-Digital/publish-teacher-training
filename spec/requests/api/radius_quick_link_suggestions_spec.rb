# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::RadiusQuickLinkSuggestions", type: :request do
  describe "GET /api/radius_quick_link_suggestions" do
    before do
      host! "www.find-example.com"
    end

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
        reading_site = build(:site, latitude: 51.4550, longitude: -0.9711)
        peterborough_site = build(:site, latitude: 52.5769, longitude: -0.2424)
        birmingham_site = build(:site, latitude: 52.4862, longitude: -1.8904)

        create(:course, :secondary, subjects: [subject_record], site_statuses: [
          build(:site_status, :findable, site: reading_site),
        ])

        create(:course, :secondary, subjects: [subject_record], site_statuses: [
          build(:site_status, :findable, site: peterborough_site),
        ])

        create(:course, :secondary, subjects: [subject_record], site_statuses: [
          build(:site_status, :findable, site: birmingham_site),
        ])
      end

      it "returns quick link suggestions for 50, 100, and 200 mile buckets" do
        get "/api/radius_quick_link_suggestions", params: search_params

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json.map { |l| l["text"] }).to include(
          a_string_matching(/^50 miles \(1 course\)/i),
          a_string_matching(/^100 miles \(2 courses\)/i),
          a_string_matching(/^200 miles \(3 courses\)/i),
        )
      end
    end

    context "when a bucket has over 100 results" do
      before do
        101.times do
          create(:course, :secondary, subjects: [find_or_create(:secondary_subject, :mathematics)], site_statuses: [
            build(:site_status, :findable, site: build(:site, latitude: 51.5074, longitude: -0.1278)),
          ])
        end
      end

      it "returns a single suggestion with 100+ courses text" do
        get "/api/radius_quick_link_suggestions", params: search_params

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json.first["text"]).to match(/^1 mile \(more than 100 courses\)/i)
      end
    end
  end
end
