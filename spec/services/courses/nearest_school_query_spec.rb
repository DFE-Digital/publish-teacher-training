# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::NearestSchoolQuery do
  subject(:results) { described_class.new(courses:, latitude:, longitude:).call }

  let(:latitude) { london.latitude }
  let(:longitude) { london.longitude }

  let(:london) { build(:location, :london) }
  let(:manchester) { build(:location, :manchester) }
  let(:cambridge) { build(:location, :cambridge) }
  let(:edinburgh) { build(:location, :edinburgh) }

  let(:london_school) do
    create(:site, provider: london_provider, urn: london_gias_school.urn, latitude: london.latitude, longitude: london.longitude)
  end
  let(:manchester_school) do
    create(:site, latitude: manchester.latitude, longitude: manchester.longitude)
  end
  let(:cambridge_school) do
    create(:site, latitude: cambridge.latitude, longitude: cambridge.longitude)
  end

  let(:london_course) do
    create(
      :course,
      name: "Mathematics (London)",
      provider: london_provider,
      site_statuses: [
        create(:site_status, :findable, site: london_school),
        create(:site_status, :findable, site: create(:site, latitude: edinburgh.latitude, longitude: edinburgh.longitude)),
      ],
    )
  end

  let(:manchester_course) do
    create(
      :course,
      name: "Physics (Manchester)",
      provider: manchester_provider,
      site_statuses: [
        create(:site_status, :findable, site: manchester_school),
        create(:site_status, :findable, site: create(:site, latitude: edinburgh.latitude, longitude: edinburgh.longitude)),
      ],
    )
  end

  let(:cambridge_course) do
    create(
      :course,
      name: "Chemistry (Cambridge)",
      provider: cambridge_provider,
      site_statuses: [
        create(:site_status, :findable, site: cambridge_school),
        create(:site_status, :findable, site: create(:site, latitude: edinburgh.latitude, longitude: edinburgh.longitude)),
      ],
    )
  end

  let(:london_provider) { create(:provider, provider_name: "London Provider") }
  let(:manchester_provider) { create(:provider, provider_name: "Manchester Provider") }
  let(:cambridge_provider) { create(:provider, provider_name: "Cambridge Provider") }
  let(:london_gias_school) { create(:gias_school) }

  let(:courses) { [london_course, manchester_course, cambridge_course] }

  before do
    create(:provider_school, provider: london_provider, gias_school: london_gias_school, site_code: london_school.code)
  end

  it "returns only the nearest school for each course" do
    expect(results).to match_collection(
      [
        london_course,
        cambridge_course,
        manchester_course,
      ],
      attribute_names: %i[id],
    )

    expect(results.map(&:site_id)).to contain_exactly(london_school.id, cambridge_school.id, manchester_school.id)
  end

  it "returns the legacy site and provider school uuids for the nearest school" do
    result = results.find { |course| course.id == london_course.id }

    expect(result.site_uuid).to eq(london_school.uuid)
    expect(result.provider_school_uuid).to eq(london_provider.schools.find_by!(gias_school: london_gias_school).uuid)
  end

  it "returns a nil provider school uuid when there is no matching provider school" do
    result = results.find { |course| course.id == manchester_course.id }

    expect(result.site_uuid).to eq(manchester_school.uuid)
    expect(result.provider_school_uuid).to be_nil
  end

  it "orders results by distance from search location" do
    distances = results.map(&:distance_to_search_location)
    expect(distances).to eq(distances.sort)
  end
end
