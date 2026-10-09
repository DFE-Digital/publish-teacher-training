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
      )
    end

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

  context "when a course runs at more than one school" do
    let(:provider) { build(:provider, provider_code: "T92") }
    let(:course) do
      create(
        :course,
        :published,
        course_code: "X102",
        provider:,
        site_statuses: build_list(:site_status, 2, :findable),
      )
    end

    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
      course

      get "/sitemap.xml"
    end

    it "lists the course once" do
      expect(response.body.scan("<loc>http://find.localhost/course/T92/X102</loc>").size).to eq(1)
    end
  end

  context "when a course is an undergraduate teacher degree apprenticeship" do
    let(:provider) { build(:provider, provider_code: "T92") }
    let(:course) do
      create(
        :course,
        :published_teacher_degree_apprenticeship,
        course_code: "X102",
        provider:,
        site_statuses: [build(:site_status, :findable)],
      )
    end

    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
      course

      get "/sitemap.xml"
    end

    it "lists the course" do
      expect(response.body).to include("<loc>http://find.localhost/course/T92/X102</loc>")
    end
  end

  context "when the course is not published" do
    let(:provider) { build(:provider, provider_code: "T92") }

    before { Timecop.travel(Find::CycleTimetable.mid_cycle) }

    it "omits a draft course" do
      create(:course, :draft_enrichment, course_code: "X102", provider:)

      get "/sitemap.xml"

      expect(response.body).not_to include("http://find.localhost/course/T92/X102")
    end

    it "omits a withdrawn course" do
      create(:course, :withdrawn, course_code: "X102", provider:)

      get "/sitemap.xml"

      expect(response.body).not_to include("http://find.localhost/course/T92/X102")
    end

    it "omits a rolled-over course" do
      create(
        :course,
        course_code: "X102",
        provider:,
        enrichments: [build(:course_enrichment, :rolled_over)],
      )

      get "/sitemap.xml"

      expect(response.body).not_to include("http://find.localhost/course/T92/X102")
    end
  end
end
