# frozen_string_literal: true

require "rails_helper"

# The nearest-school lookup over the canonical course_school -> gias_school model,
# gated by the :course_publishing_uses_new_school_model flag. Distances come from
# gias_school coordinates instead of course_site -> site, so a course that only has
# Course::School / Provider::School records - with no legacy Site or SiteStatus -
# still resolves a distance. The expected miles below are the same values the
# location search pins in spec/services/courses/query/location_new_school_model_spec.rb.
RSpec.describe Courses::NearestSchoolQuery do
  subject(:results) { described_class.new(courses:, latitude: london.latitude, longitude: london.longitude).call }

  before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }
  after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

  let(:london) { build(:location, :london) }
  let(:canary_wharf) { build(:location, :canary_wharf) }
  let(:cambridge) { build(:location, :cambridge) }
  let(:edinburgh) { build(:location, :edinburgh) }

  let(:courses) { [course] }

  # A course taught at each of `locations`, with no legacy Site or SiteStatus.
  def course_taught_at(*locations, name: "Mathematics", provider: create(:provider))
    create(:course, name:, provider:).tap do |course|
      locations.each { |location| attach_school(course, location) }
    end
  end

  def attach_school(course, location, **options)
    create(
      :course_school,
      course:,
      gias_school: create(:gias_school, latitude: location&.latitude, longitude: location&.longitude),
      **options,
    )
  end

  context "when a course has only canonical schools" do
    let(:course) { course_taught_at(canary_wharf) }

    it "returns one row per course with the distance to the search location" do
      expect(course.site_statuses).to be_empty
      expect(results.size).to eq(1)
      expect(results.first.distance_to_search_location).to be_within(0.01).of(4.46)
    end

    it "returns the school's name, coordinates and provider school uuid" do
      course_school = course.schools.sole
      result = results.first

      expect(result.location_name).to eq(course_school.gias_school.name)
      expect(result.latitude).to eq(canary_wharf.latitude)
      expect(result.longitude).to eq(canary_wharf.longitude)
      expect(result.provider_school_uuid).to eq(course_school.provider_school.uuid)
    end

    it "labels a main site school the way Provider::School does" do
      main_site_course = create(:course).tap { |c| attach_school(c, cambridge, site_code: Provider::School::MAIN_SITE_CODE) }
      result = described_class.new(courses: [main_site_course], latitude: london.latitude, longitude: london.longitude).call.first

      expect(result.location_name).to eq("#{main_site_course.schools.sole.gias_school.name} (Main Site)")
    end
  end

  context "when a course has several schools" do
    let(:course) { course_taught_at(edinburgh, canary_wharf, cambridge) }

    it "returns only the nearest one" do
      expect(results.size).to eq(1)
      expect(results.first.distance_to_search_location).to be_within(0.01).of(4.46)
      expect(results.first.latitude).to eq(canary_wharf.latitude)
    end
  end

  context "when several courses match" do
    let(:cambridge_course) { course_taught_at(cambridge, name: "Chemistry (Cambridge)") }
    let(:canary_wharf_course) { course_taught_at(canary_wharf, name: "Science (Canary Wharf)") }
    let(:edinburgh_course) { course_taught_at(edinburgh, name: "Physics (Edinburgh)") }
    let(:courses) { [edinburgh_course, cambridge_course, canary_wharf_course] }

    it "orders them by distance from the search location" do
      expect(results.map(&:id)).to eq([canary_wharf_course.id, cambridge_course.id, edinburgh_course.id])
    end
  end

  context "when a school has no coordinates" do
    let(:course) { course_taught_at(cambridge) }

    it "ignores it in favour of a school that has them" do
      attach_school(course, nil)

      expect(results.size).to eq(1)
      expect(results.first.latitude).to eq(cambridge.latitude)
    end

    it "returns no row when it is the course's only school" do
      ungeocoded_course = create(:course).tap { |c| attach_school(c, nil) }

      expect(described_class.new(courses: [ungeocoded_course], latitude: london.latitude, longitude: london.longitude).call).to be_empty
    end
  end

  context "when a course is linked to the same GIAS school twice" do
    let(:course) { create(:course) }

    it "returns a single row with the correct distance" do
      gias_school = create(:gias_school, latitude: canary_wharf.latitude, longitude: canary_wharf.longitude)
      create(:course_school, course:, gias_school:, site_code: "A")
      create(:course_school, course:, gias_school:, site_code: "B")

      expect(results.size).to eq(1)
      expect(results.first.distance_to_search_location).to be_within(0.01).of(4.46)
    end

    # Both rows tie on distance and on gias_school.id, so without a further
    # tiebreaker Postgres is free to return either provider school - and the
    # ?debug panel's link and "(Main Site)" label would flip between page loads.
    it "always picks the same provider school of the two" do
      gias_school = create(:gias_school, latitude: canary_wharf.latitude, longitude: canary_wharf.longitude)
      main_site = create(:course_school, :main_site, course:, gias_school:).provider_school
      create(:course_school, course:, gias_school:, site_code: "A")

      5.times do
        result = described_class.new(courses: [course], latitude: london.latitude, longitude: london.longitude).call.first

        expect(result.provider_school_uuid).to eq(main_site.uuid)
        expect(result.location_name).to eq("#{gias_school.name} (Main Site)")
      end
    end
  end
end
