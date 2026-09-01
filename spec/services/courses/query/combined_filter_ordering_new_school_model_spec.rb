# frozen_string_literal: true

require "rails_helper"

# Combined filter + ordering coverage for the canonical course_school -> gias_school
# location path, gated by :course_publishing_uses_new_school_model. The sibling
# combined_filter_ordering_spec.rb covers the same combinations over the legacy
# course_site -> site path.
#
# schools_location_scope annotates each course with a distance taken from a derived
# table while the fee and newest_course orderings add a GROUP BY of their own, and
# subjects_scope joins a has_many. All three have to agree on the grouping, or
# Postgres rejects the query and duplicate courses reach the results page.
RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }
  after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

  let(:alpha_provider) { create(:provider, provider_name: "Alpha University") }
  let(:beta_provider) { create(:provider, provider_name: "Beta University") }
  let(:london) { build(:location, :london) }
  let(:canary_wharf) { build(:location, :canary_wharf) }
  let(:cambridge) { build(:location, :cambridge) }

  # Teaches an existing course at each location, one gias_school per location.
  def teach_at(course, *locations)
    locations.each do |location|
      create(
        :course_school,
        course:,
        gias_school: create(:gias_school, latitude: location.latitude, longitude: location.longitude),
      )
    end
    course
  end

  context "when combining location filter with fee_uk_ascending ordering" do
    let(:params) { { order: "fee_uk_ascending", latitude: london.latitude, longitude: london.longitude, radius: 10 } }

    let!(:nearby_low_fee) do
      teach_at(
        create(:course, :published, :fee, name: "Low Fee Nearby", provider: alpha_provider,
                                          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)]),
        london,
      )
    end
    let!(:nearby_high_fee) do
      teach_at(
        create(:course, :published, :fee, name: "High Fee Nearby", provider: beta_provider,
                                          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000)]),
        canary_wharf,
      )
    end
    let!(:far_low_fee) do
      teach_at(
        create(:course, :published, :fee, name: "Low Fee Far", provider: alpha_provider,
                                          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 1000)]),
        cambridge,
      )
    end

    it "returns only nearby courses ordered by UK fee ascending" do
      expect(results).to match_collection([nearby_low_fee, nearby_high_fee], attribute_names: %w[name])
    end
  end

  context "when combining location filter with fee_intl_ascending ordering" do
    let(:params) { { order: "fee_intl_ascending", latitude: london.latitude, longitude: london.longitude, radius: 10 } }

    let!(:nearby_low_fee) do
      teach_at(
        create(:course, :published, :fee, name: "Low Intl Fee Nearby", provider: alpha_provider,
                                          enrichments: [build(:course_enrichment, :published, fee_international: 12_000)]),
        london,
      )
    end
    let!(:nearby_high_fee) do
      teach_at(
        create(:course, :published, :fee, name: "High Intl Fee Nearby", provider: beta_provider,
                                          enrichments: [build(:course_enrichment, :published, fee_international: 18_000)]),
        canary_wharf,
      )
    end
    let!(:far_low_fee) do
      teach_at(
        create(:course, :published, :fee, name: "Low Intl Fee Far", provider: alpha_provider,
                                          enrichments: [build(:course_enrichment, :published, fee_international: 5000)]),
        cambridge,
      )
    end

    it "returns only nearby courses ordered by international fee ascending" do
      expect(results).to match_collection([nearby_low_fee, nearby_high_fee], attribute_names: %w[name])
    end
  end

  context "when combining location filter with newest_course ordering" do
    let(:params) { { order: "newest_course", latitude: london.latitude, longitude: london.longitude, radius: 10 } }

    let!(:nearby_recent) do
      teach_at(
        create(:course, :published, name: "Nearby Recent", provider: alpha_provider,
                                    enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)]),
        london,
      )
    end
    let!(:nearby_old) do
      teach_at(
        create(:course, :published, name: "Nearby Old", provider: beta_provider,
                                    enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 5.days.ago)]),
        canary_wharf,
      )
    end
    let!(:far_recent) do
      teach_at(
        create(:course, :published, name: "Far Recent", provider: alpha_provider,
                                    enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.hour.ago)]),
        cambridge,
      )
    end

    it "returns only nearby courses ordered by newest first" do
      expect(results).to match_collection([nearby_recent, nearby_old], attribute_names: %w[name])
    end
  end

  context "when a nearby course is taught at several schools and a fee ordering is applied" do
    let(:params) { { order: "fee_uk_ascending", latitude: london.latitude, longitude: london.longitude, radius: 10 } }

    let!(:multi_school_course) do
      teach_at(
        create(:course, :published, :fee, name: "Multi School", provider: alpha_provider,
                                          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)]),
        cambridge,
        canary_wharf,
        london,
      )
    end

    it "returns the course once, at the distance of its nearest school" do
      rows = results.to_a

      expect(rows.size).to eq(1)
      expect(rows.first.minimum_distance_to_search_location.round(2)).to eq(0.0)
    end
  end
end
