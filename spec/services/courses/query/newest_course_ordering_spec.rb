# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  let(:alpha_provider) { create(:provider, provider_name: "Alpha University") }
  let(:beta_provider) { create(:provider, provider_name: "Beta University") }

  context "when combined with subject filter" do
    let(:physics_subject) { find_or_create(:secondary_subject, :physics) }
    let(:biology_subject) { find_or_create(:secondary_subject, :biology) }

    let!(:physics_recent) do
      create(:course, :with_full_time_sites, :secondary, name: "Physics Recent",
                                                         provider: alpha_provider, subjects: [physics_subject],
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)])
    end
    let!(:physics_old) do
      create(:course, :with_full_time_sites, :secondary, name: "Physics Old",
                                                         provider: beta_provider, subjects: [physics_subject],
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 5.days.ago)])
    end
    let!(:biology_newest) do
      create(:course, :with_full_time_sites, :secondary, name: "Biology Newest",
                                                         provider: alpha_provider, subjects: [biology_subject],
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.hour.ago)])
    end

    let(:params) { { order: "newest_course", subjects: [physics_subject.subject_code] } }

    it "returns only matching subject courses ordered by newest first" do
      expect(results).to match_collection(
        [physics_recent, physics_old],
        attribute_names: %w[name],
      )
    end
  end

  context "when combined with location filter" do
    let!(:nearby_recent) do
      create(:course, :with_full_time_sites, name: "Nearby Recent",
                                             provider: alpha_provider,
                                             enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)])
    end
    let(:params) { { order: "newest_course", latitude: 51.5074, longitude: -0.1278, radius: 10 } }
    let!(:nearby_old) do
      create(:course, :with_full_time_sites, name: "Nearby Old",
                                             provider: beta_provider,
                                             enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 5.days.ago)])
    end

    before do
      nearby_recent.site_statuses.first.site.update!(latitude: 51.5074, longitude: -0.1278)
      nearby_old.site_statuses.first.site.update!(latitude: 51.5080, longitude: -0.1280)
    end

    it "returns location-filtered courses ordered by newest first" do
      expect(results).to match_collection(
        [nearby_recent, nearby_old],
        attribute_names: %w[name],
      )
    end
  end

  context "when combined with visa sponsorship filter" do
    let!(:visa_recent) do
      create(:course, :with_full_time_sites, name: "Visa Recent",
                                             provider: alpha_provider, can_sponsor_skilled_worker_visa: true,
                                             enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)])
    end
    let!(:visa_old) do
      create(:course, :with_full_time_sites, name: "Visa Old",
                                             provider: beta_provider, can_sponsor_skilled_worker_visa: true,
                                             enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 5.days.ago)])
    end
    let!(:no_visa_newest) do
      create(:course, :with_full_time_sites, name: "No Visa Newest",
                                             provider: alpha_provider, can_sponsor_skilled_worker_visa: false,
                                             enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.hour.ago)])
    end

    let(:params) { { order: "newest_course", can_sponsor_visa: true } }

    it "returns only visa-sponsoring courses ordered by newest first" do
      expect(results).to match_collection(
        [visa_recent, visa_old],
        attribute_names: %w[name],
      )
    end
  end
end
