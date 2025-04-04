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
    create(:site, latitude: london.latitude, longitude: london.longitude)
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

  let(:courses) { [london_course, manchester_course, cambridge_course] }

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

  it "orders results by distance from search location" do
    distances = results.map(&:distance_to_search_location)
    expect(distances).to eq(distances.sort)
  end
end
