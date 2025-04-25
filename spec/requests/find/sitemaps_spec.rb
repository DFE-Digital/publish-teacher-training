# frozen_string_literal: true

require "rails_helper"

describe "/sitemap.xml", service: :find do
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
