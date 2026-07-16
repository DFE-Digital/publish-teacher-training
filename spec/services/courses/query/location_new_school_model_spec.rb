# frozen_string_literal: true

require "rails_helper"
require_relative "query_helper"

# Location search over the canonical course_school -> gias_school model, gated by
# the :course_publishing_uses_new_school_model flag. Distances are computed from
# gias_school coordinates instead of course_site -> site, so the same coordinates
# must produce the same minimum_distance_to_search_location as the legacy path
# (the values below are shared with location_params_spec.rb on purpose).
RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  include QueryHelper

  context "when :course_publishing_uses_new_school_model is active" do
    before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }
    after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

    let(:london) { build(:location, :london) }
    let!(:course_london_result) { course_at(london, name: "Mathematics (London)", distance: 0.0) }
    let!(:course_canary_wharf_result) { course_at(canary_wharf, name: "Science (Canary Wharf)", distance: 4.46) }
    let!(:course_lewisham_result) { course_at(lewisham, name: "Science (Lewisham)", distance: 6.07) }
    let!(:course_romford_result) { course_at(romford, name: "Science (Romford)", distance: 14.36) }
    let!(:course_cambridge_result) { course_at(cambridge, name: "Chemistry (Cambridge)", distance: 49.38) }
    let(:canary_wharf) { build(:location, :canary_wharf) }
    let(:lewisham) { build(:location, :lewisham) }
    let(:romford) { build(:location, :romford) }
    let(:cambridge) { build(:location, :cambridge) }

    # Builds a published course taught at a single gias_school at `location`,
    # wrapped with its expected distance for match_collection assertions.
    def course_at(location, name:, distance:, provider: nil)
      course = create(:course, :published, name:, provider: provider || create(:provider))
      create(
        :course_school,
        course:,
        gias_school: create(:gias_school, latitude: location.latitude, longitude: location.longitude),
      )
      test_search_result_wrapper_klass.new(course, minimum_distance_to_search_location: distance)
    end

    it_behaves_like "location search results", radius: 10 do
      let(:expected) { [course_london_result, course_canary_wharf_result, course_lewisham_result] }
    end

    it_behaves_like "location search results", radius: 20 do
      let(:expected) do
        [course_london_result, course_canary_wharf_result, course_lewisham_result, course_romford_result]
      end
    end

    it_behaves_like "location search results", radius: 50 do
      let(:expected) do
        [
          course_london_result,
          course_canary_wharf_result,
          course_lewisham_result,
          course_romford_result,
          course_cambridge_result,
        ]
      end
    end

    it "defaults to ordering by distance when latitude and longitude are given" do
      results = described_class.call(
        params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
      )

      expect(results).to match_collection(
        [course_london_result, course_canary_wharf_result, course_lewisham_result],
        attribute_names: %w[name minimum_distance_to_search_location],
      )
    end

    context "when a course is taught only at a non-school site (no course_school edge)" do
      # The accepted behaviour change: with course_school as the sole source, a
      # published course whose only location is a non-GIAS site drops out of
      # location search (it still appears in non-location search).
      let!(:non_school_course) do
        create(
          :course,
          :published,
          name: "Campus Only",
          site_statuses: [
            create(
              :site_status,
              :findable,
              site: create(:site, latitude: london.latitude, longitude: london.longitude),
            ),
          ],
        )
      end

      it "is excluded from location search" do
        results = described_class.call(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
        )

        expect(results.map(&:name)).not_to include("Campus Only")
      end
    end

    context "when a gias_school is shared across providers" do
      let(:shared_school) do
        create(:gias_school, latitude: london.latitude, longitude: london.longitude)
      end
      let(:apple_provider) { create(:provider, provider_name: "Apple University") }
      let(:zebra_provider) { create(:provider, provider_name: "Zebra University") }

      before do
        [apple_provider, zebra_provider].each do |provider|
          course = create(:course, :published, provider:)
          create(:course_school, course:, gias_school: shared_school)
        end
      end

      it "returns each course once, deduplicated by the shared school" do
        results = described_class.call(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
        ).to_a

        shared = results.select { |c| [apple_provider.id, zebra_provider.id].include?(c.provider_id) }
        expect(shared.map { |c| c.provider.provider_name }).to eq(["Apple University", "Zebra University"])
        expect(shared.map(&:minimum_distance_to_search_location).map { |d| d.round(2) }).to eq([0.0, 0.0])
      end
    end

    context "when a course is taught at several schools" do
      let(:oxford) { build(:location, :oxford) }

      # Cambridge (~49mi) and Oxford (~51mi) are outside a 10mi radius; Canary
      # Wharf (~4.46mi) is inside. The nearest in-radius school should win.
      let!(:multi_school_course) do
        course = create(:course, :published, name: "Multi School", provider: create(:provider))
        [cambridge, canary_wharf, oxford].each do |location|
          create(
            :course_school,
            course:,
            gias_school: create(:gias_school, latitude: location.latitude, longitude: location.longitude),
          )
        end
        course
      end

      it "returns the course once, at the distance of its nearest school" do
        results = described_class.call(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
        ).to_a

        rows = results.select { |c| c.id == multi_school_course.id }
        expect(rows.size).to eq(1)
        expect(rows.first.minimum_distance_to_search_location.round(2)).to eq(4.46)
      end
    end

    context "when all of a course's schools are outside the radius" do
      let(:oxford) { build(:location, :oxford) }

      let!(:far_course) do
        course = create(:course, :published, name: "Far Away", provider: create(:provider))
        [cambridge, oxford].each do |location|
          create(
            :course_school,
            course:,
            gias_school: create(:gias_school, latitude: location.latitude, longitude: location.longitude),
          )
        end
        course
      end

      it "is excluded" do
        results = described_class.call(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
        )

        expect(results.map(&:name)).not_to include("Far Away")
      end
    end

    context "when a course has a school with no coordinates" do
      # The gias_school factory leaves latitude/longitude nil unless set, mirroring
      # GIAS rows still awaiting geocoding. The coords guard must skip such schools.
      let!(:partly_geocoded_course) do
        course = create(:course, :published, name: "Partly Geocoded", provider: create(:provider))
        create(:course_school, course:, gias_school: create(:gias_school))
        create(
          :course_school,
          course:,
          gias_school: create(:gias_school, latitude: london.latitude, longitude: london.longitude),
        )
        course
      end

      let!(:ungeocoded_only_course) do
        course = create(:course, :published, name: "No Coordinates", provider: create(:provider))
        create(:course_school, course:, gias_school: create(:gias_school))
        course
      end

      it "keeps the course via its geocoded school, ignoring the ungeocoded one" do
        results = described_class.call(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
        ).to_a

        row = results.find { |c| c.id == partly_geocoded_course.id }
        expect(row).to be_present
        expect(row.minimum_distance_to_search_location.round(2)).to eq(0.0)
      end

      it "excludes a course whose only school has no coordinates" do
        results = described_class.call(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
        )

        expect(results.map(&:name)).not_to include("No Coordinates")
      end
    end

    context "when a course links the same school via two provider schools" do
      # course_school is unique on [course_id, provider_school_id], so one
      # gias_school can be reached twice by a course. MIN + GROUP BY must collapse
      # it to a single result row.
      let!(:duplicate_edge_course) do
        course = create(:course, :published, name: "Duplicate Edge", provider: create(:provider))
        school = create(:gias_school, latitude: london.latitude, longitude: london.longitude)
        create(:course_school, course:, gias_school: school, site_code: "A")
        create(:course_school, course:, gias_school: school, site_code: "B")
        course
      end

      it "returns the course exactly once" do
        results = described_class.call(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
        ).to_a

        rows = results.select { |c| c.id == duplicate_edge_course.id }
        expect(rows.size).to eq(1)
        expect(rows.first.minimum_distance_to_search_location.round(2)).to eq(0.0)
      end
    end

    context "when combined with a subject filter (filter-led search)" do
      let!(:biology_course) do
        course = create(
          :course, :published, :secondary,
          name: "Biology",
          provider: create(:provider),
          subjects: [find_or_create(:secondary_subject, :biology)]
        )
        create(:course_school, course:, gias_school: create(:gias_school, latitude: london.latitude, longitude: london.longitude))
        course
      end

      let!(:physics_course) do
        course = create(
          :course, :published, :secondary,
          name: "Physics",
          provider: create(:provider),
          subjects: [find_or_create(:secondary_subject, :physics)]
        )
        create(:course_school, course:, gias_school: create(:gias_school, latitude: london.latitude, longitude: london.longitude))
        course
      end

      it "returns only courses matching both the subject and the location" do
        results = described_class.call(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10, subject_code: "C1" },
        )

        names = results.map(&:name)
        expect(names).to include("Biology")
        expect(names).not_to include("Physics")
      end
    end

    describe "#count" do
      it "counts distinct courses within the radius" do
        query = described_class.new(
          params: { latitude: london.latitude, longitude: london.longitude, radius: 10 },
        )
        query.call

        # Of the five seeded courses only London (0mi), Canary Wharf (4.46mi) and
        # Lewisham (6.07mi) fall within 10 miles.
        expect(query.count).to eq(3)
      end
    end
  end
end
