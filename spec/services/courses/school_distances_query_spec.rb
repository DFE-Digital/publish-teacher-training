# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::SchoolDistancesQuery do
  subject(:query_result) { described_class.new(courses:, latitude:, longitude:).call }

  let(:courses) { [london_course, manchester_course, cambridge_course] }

  let(:latitude) { 51.5 }
  let(:longitude) { -0.1 }
  let(:london) { build(:location, :london) }
  let(:canary_wharf) { build(:location, :canary_wharf) }
  let(:manchester) { build(:location, :manchester) }
  let(:cambridge) { build(:location, :cambridge) }

  let!(:london_course) do
    create(:course, provider: create(:provider), site_statuses: [
      create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude)),
      create(:site_status, :findable, site: create(:site, latitude: canary_wharf.latitude, longitude: canary_wharf.longitude)),
    ])
  end

  let!(:manchester_course) do
    create(:course, provider: create(:provider), site_statuses: [
      create(:site_status, :findable, site: create(:site, latitude: manchester.latitude, longitude: manchester.longitude)),
    ])
  end

  let!(:cambridge_course) do
    create(:course, provider: create(:provider), site_statuses: [
      create(:site_status, :findable, site: create(:site, latitude: cambridge.latitude, longitude: cambridge.longitude)),
    ])
  end

  # Exact rather than rounded, so a change to the distance maths has to be
  # deliberate. The values are metres from PostGIS divided by
  # Geolocation::METRES_PER_MILE; they last moved when this path stopped using a
  # truncated 1609.34.
  it "includes the distance to the search location in miles for each school" do
    expect(query_result.map(&:distance_to_search_location)).to eq(
      [
        1.3003627104894913,
        3.2706343745153306,
        163.86122704434848,
        49.64238076525591,
      ],
    )
  end

  it "orders results by course id for each school" do
    expect(
      query_result.map(&:course_id),
    ).to eq(
      [
        london_course.id,
        london_course.id,
        manchester_course.id,
        cambridge_course.id,
      ],
    )
  end
end
