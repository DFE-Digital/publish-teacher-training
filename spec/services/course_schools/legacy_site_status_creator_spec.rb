# frozen_string_literal: true

require "rails_helper"

describe CourseSchools::LegacySiteStatusCreator do
  let(:provider) { create(:provider) }
  let(:site) { create(:site, provider:) }
  let(:course) { create(:course, provider:, sites: []) }

  it "attaches the site to the course via a SiteStatus row" do
    expect {
      described_class.call(course:, site:)
    }.to change { course.site_statuses.count }.by(1)

    expect(course.site_statuses.last.site).to eq(site)
  end

  it "is idempotent when called twice with the same site" do
    described_class.call(course:, site:)

    expect {
      described_class.call(course:, site:)
    }.not_to(change { course.site_statuses.count })
  end
end
