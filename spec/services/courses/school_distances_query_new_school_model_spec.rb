# frozen_string_literal: true

require "rails_helper"

# The per-school distance listing behind Find's ?debug panel, over the canonical
# course_school -> gias_school model and gated by the
# :course_publishing_uses_new_school_model flag. Unlike the nearest-school lookup
# this keeps every school a course is taught at, so the panel can show them all -
# but only once each, however many Provider::Schools point at the same GiasSchool.
RSpec.describe Courses::SchoolDistancesQuery do
  subject(:results) { described_class.new(courses:, latitude: london.latitude, longitude: london.longitude).call }

  before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }
  after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

  let(:london) { build(:location, :london) }
  let(:canary_wharf) { build(:location, :canary_wharf) }
  let(:cambridge) { build(:location, :cambridge) }
  let(:edinburgh) { build(:location, :edinburgh) }

  let(:courses) { [course] }

  def attach_school(course, location, **options)
    create(
      :course_school,
      course:,
      gias_school: create(:gias_school, latitude: location&.latitude, longitude: location&.longitude),
      **options,
    )
  end

  context "when a course has only canonical schools" do
    let(:course) { create(:course) }

    it "returns every school, nearest first, with its distance and details" do
      attach_school(course, cambridge)
      attach_school(course, canary_wharf)

      expect(course.site_statuses).to be_empty
      expect(results.map(&:distance_to_search_location)).to match([
        a_value_within(0.01).of(4.46),
        a_value_within(0.01).of(49.38),
      ])
      expect(results.map(&:latitude)).to eq([canary_wharf.latitude, cambridge.latitude])
      expect(results.map(&:location_name)).to eq(
        course.schools.map { |school| school.gias_school.name }.values_at(1, 0),
      )
    end
  end

  context "when several courses are given" do
    let(:cambridge_course) { create(:course).tap { |c| attach_school(c, cambridge) } }
    let(:canary_wharf_course) { create(:course).tap { |c| attach_school(c, canary_wharf) } }
    let(:courses) { [cambridge_course, canary_wharf_course] }

    it "groups the schools by course" do
      expect(results.map(&:course_id)).to eq([cambridge_course.id, canary_wharf_course.id].sort)
    end
  end

  context "when a course is linked to the same GIAS school twice" do
    let(:course) { create(:course) }

    it "returns the school once" do
      gias_school = create(:gias_school, latitude: canary_wharf.latitude, longitude: canary_wharf.longitude)
      create(:course_school, course:, gias_school:, site_code: "A")
      create(:course_school, course:, gias_school:, site_code: "B")

      expect(results.size).to eq(1)
      expect(results.first.distance_to_search_location).to be_within(0.01).of(4.46)
    end
  end

  context "when a school has no coordinates" do
    let(:course) { create(:course) }

    it "leaves it out" do
      attach_school(course, edinburgh)
      attach_school(course, nil)

      expect(results.map(&:latitude)).to eq([edinburgh.latitude])
    end
  end
end
