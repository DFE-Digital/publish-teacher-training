# frozen_string_literal: true

require "rails_helper"

describe "/sitemap.xml" do
  context "when rendering the sitemap" do
    let(:provider_code) { "T92" }
    let(:provider) { build(:provider, provider_code:) }
    let(:changed_at) { Time.zone.now }
    let(:course_code) { "X102" }
    let(:course) do
      create(
        :course,
        :published,
        course_code:,
        provider:,
        changed_at:,
        site_statuses: [site_status],
      )
    end

    let(:site_status) { build(:site_status, :running, :published, site: site1) }

    let(:site1) { build(:site, location_name: "location 1") }

    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
      course

      get "/sitemap.xml"
    end

    it "renders sitemap" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(
        <<~XML,
          <?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns="http://www.google.com/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
            <url>
              <loc>http://find.localhost/</loc>
            </url>
            <url>
              <loc>http://find.localhost/results</loc>
            </url>
            <url>
              <loc>http://find.localhost/course/#{provider_code}/#{course_code}</loc>
              <lastmod>#{changed_at.to_date.strftime('%Y-%m-%d')}</lastmod>
            </url>
          </urlset>
        XML
      )
    end
  end

  describe "when the new school model feature flag is active" do
    before do
      FeatureFlag.activate(:course_publishing_uses_new_school_model)

      allow(CourseSearchService).to receive(:call).and_return(Course.none)
      allow(CourseSearchServiceSchools).to receive(:call).and_return(Course.none)
    end

    context "when the current recruitment cycle is 2026 or earlier", travel: mid_cycle(2026) do
      it "uses the sites course search service" do
        get "/sitemap.xml"

        expect(CourseSearchService).to have_received(:call)
        expect(CourseSearchServiceSchools).not_to have_received(:call)
      end
    end

    context "when the current recruitment cycle is 2027 or later", travel: mid_cycle(2027) do
      it "uses the schools course search service" do
        get "/sitemap.xml"

        expect(CourseSearchServiceSchools).to have_received(:call)
        expect(CourseSearchService).not_to have_received(:call)
      end
    end
  end
end
