# frozen_string_literal: true

require "rails_helper"

describe CourseSchools::LegacySiteStatusRemover do
  let(:provider) { create(:provider) }
  let(:site) { create(:site, provider:) }
  let(:course) { create(:course, provider:, sites: [site]) }

  it "detaches the site from a new course by destroying the SiteStatus" do
    expect {
      described_class.call(course:, site:)
    }.to change { course.site_statuses.count }.by(-1)
  end
end
