# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  let(:alpha_provider) { create(:provider, provider_name: "Alpha University") }
  let(:beta_provider) { create(:provider, provider_name: "Beta University") }
  let(:london_latitude) { 51.5074 }
  let(:london_longitude) { -0.1278 }

  context "when combining location filter with fee_uk_ascending ordering" do
    let(:params) { { order: "fee_uk_ascending", latitude: london_latitude, longitude: london_longitude, radius: 10 } }

    let!(:nearby_low_fee) do
      create(:course, :with_full_time_sites, :fee, name: "Low Fee Nearby",
                                                   provider: alpha_provider,
                                                   enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)])
    end
    let!(:nearby_high_fee) do
      create(:course, :with_full_time_sites, :fee, name: "High Fee Nearby",
                                                   provider: beta_provider,
                                                   enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000)])
    end
    let!(:far_away_low_fee) do
      create(:course, :with_full_time_sites, :fee, name: "Low Fee Far",
                                                   provider: alpha_provider,
                                                   enrichments: [build(:course_enrichment, :published, fee_uk_eu: 1000)])
    end

    before do
      nearby_low_fee.site_statuses.first.site.update!(latitude: london_latitude, longitude: london_longitude)
      nearby_high_fee.site_statuses.first.site.update!(latitude: 51.5080, longitude: -0.1280)
      far_away_low_fee.site_statuses.first.site.update!(latitude: 55.0, longitude: -1.5)
    end

    it "returns only nearby courses ordered by UK fee ascending" do
      expect(results).to match_collection(
        [nearby_low_fee, nearby_high_fee],
        attribute_names: %w[name],
      )
    end
  end

  context "when combining location filter with fee_intl_ascending ordering" do
    let(:params) { { order: "fee_intl_ascending", latitude: london_latitude, longitude: london_longitude, radius: 10 } }

    let!(:nearby_low_fee) do
      create(:course, :with_full_time_sites, :fee, name: "Low Intl Fee Nearby",
                                                   provider: alpha_provider,
                                                   enrichments: [build(:course_enrichment, :published, fee_international: 12_000)])
    end
    let!(:nearby_high_fee) do
      create(:course, :with_full_time_sites, :fee, name: "High Intl Fee Nearby",
                                                   provider: beta_provider,
                                                   enrichments: [build(:course_enrichment, :published, fee_international: 18_000)])
    end
    let!(:far_away_low_fee) do
      create(:course, :with_full_time_sites, :fee, name: "Low Intl Fee Far",
                                                   provider: alpha_provider,
                                                   enrichments: [build(:course_enrichment, :published, fee_international: 5000)])
    end

    before do
      nearby_low_fee.site_statuses.first.site.update!(latitude: london_latitude, longitude: london_longitude)
      nearby_high_fee.site_statuses.first.site.update!(latitude: 51.5080, longitude: -0.1280)
      far_away_low_fee.site_statuses.first.site.update!(latitude: 55.0, longitude: -1.5)
    end

    it "returns only nearby courses ordered by international fee ascending" do
      expect(results).to match_collection(
        [nearby_low_fee, nearby_high_fee],
        attribute_names: %w[name],
      )
    end
  end

  context "when combining subject filter, location filter, and newest_course ordering" do
    let(:physics_subject) { find_or_create(:secondary_subject, :physics) }
    let(:biology_subject) { find_or_create(:secondary_subject, :biology) }
    let(:params) { { order: "newest_course", subjects: [physics_subject.subject_code], latitude: london_latitude, longitude: london_longitude, radius: 10 } }

    let!(:nearby_physics_recent) do
      create(:course, :with_full_time_sites, :secondary, name: "Nearby Physics Recent",
                                                         provider: alpha_provider, subjects: [physics_subject],
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)])
    end
    let!(:nearby_physics_old) do
      create(:course, :with_full_time_sites, :secondary, name: "Nearby Physics Old",
                                                         provider: beta_provider, subjects: [physics_subject],
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 5.days.ago)])
    end
    let!(:nearby_biology) do
      create(:course, :with_full_time_sites, :secondary, name: "Nearby Biology",
                                                         provider: alpha_provider, subjects: [biology_subject],
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.hour.ago)])
    end
    let!(:far_physics) do
      create(:course, :with_full_time_sites, :secondary, name: "Far Physics",
                                                         provider: alpha_provider, subjects: [physics_subject],
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.hour.ago)])
    end

    before do
      nearby_physics_recent.site_statuses.first.site.update!(latitude: london_latitude, longitude: london_longitude)
      nearby_physics_old.site_statuses.first.site.update!(latitude: 51.5080, longitude: -0.1280)
      nearby_biology.site_statuses.first.site.update!(latitude: london_latitude, longitude: london_longitude)
      far_physics.site_statuses.first.site.update!(latitude: 55.0, longitude: -1.5)
    end

    it "returns only nearby physics courses ordered by newest first" do
      expect(results).to match_collection(
        [nearby_physics_recent, nearby_physics_old],
        attribute_names: %w[name],
      )
    end
  end

  context "when combining visa filter, location filter, and fee_uk_ascending ordering" do
    let(:params) { { order: "fee_uk_ascending", can_sponsor_visa: true, latitude: london_latitude, longitude: london_longitude, radius: 10 } }

    let!(:nearby_visa_low_fee) do
      create(:course, :with_full_time_sites, :fee, name: "Visa Low Fee Nearby",
                                                   provider: alpha_provider, can_sponsor_skilled_worker_visa: true,
                                                   enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)])
    end
    let!(:nearby_visa_high_fee) do
      create(:course, :with_full_time_sites, :fee, name: "Visa High Fee Nearby",
                                                   provider: beta_provider, can_sponsor_skilled_worker_visa: true,
                                                   enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000)])
    end
    let!(:nearby_no_visa) do
      create(:course, :with_full_time_sites, :fee, name: "No Visa Nearby",
                                                   provider: alpha_provider, can_sponsor_skilled_worker_visa: false,
                                                   enrichments: [build(:course_enrichment, :published, fee_uk_eu: 3000)])
    end
    let!(:far_visa) do
      create(:course, :with_full_time_sites, :fee, name: "Visa Far",
                                                   provider: alpha_provider, can_sponsor_skilled_worker_visa: true,
                                                   enrichments: [build(:course_enrichment, :published, fee_uk_eu: 1000)])
    end

    before do
      nearby_visa_low_fee.site_statuses.first.site.update!(latitude: london_latitude, longitude: london_longitude)
      nearby_visa_high_fee.site_statuses.first.site.update!(latitude: 51.5080, longitude: -0.1280)
      nearby_no_visa.site_statuses.first.site.update!(latitude: london_latitude, longitude: london_longitude)
      far_visa.site_statuses.first.site.update!(latitude: 55.0, longitude: -1.5)
    end

    it "returns only nearby visa-sponsoring courses ordered by UK fee ascending" do
      expect(results).to match_collection(
        [nearby_visa_low_fee, nearby_visa_high_fee],
        attribute_names: %w[name],
      )
    end
  end

  context "when combining subject filter, visa filter, and newest_course ordering" do
    let(:physics_subject) { find_or_create(:secondary_subject, :physics) }
    let(:biology_subject) { find_or_create(:secondary_subject, :biology) }
    let(:params) { { order: "newest_course", subjects: [physics_subject.subject_code], can_sponsor_visa: true } }

    let!(:physics_visa_recent) do
      create(:course, :with_full_time_sites, :secondary, name: "Physics Visa Recent",
                                                         provider: alpha_provider, subjects: [physics_subject], can_sponsor_skilled_worker_visa: true,
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)])
    end
    let!(:physics_visa_old) do
      create(:course, :with_full_time_sites, :secondary, name: "Physics Visa Old",
                                                         provider: beta_provider, subjects: [physics_subject], can_sponsor_skilled_worker_visa: true,
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 5.days.ago)])
    end
    let!(:physics_no_visa) do
      create(:course, :with_full_time_sites, :secondary, name: "Physics No Visa",
                                                         provider: alpha_provider, subjects: [physics_subject], can_sponsor_skilled_worker_visa: false,
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.hour.ago)])
    end
    let!(:biology_visa) do
      create(:course, :with_full_time_sites, :secondary, name: "Biology Visa",
                                                         provider: alpha_provider, subjects: [biology_subject], can_sponsor_skilled_worker_visa: true,
                                                         enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.hour.ago)])
    end

    it "returns only physics visa-sponsoring courses ordered by newest first" do
      expect(results).to match_collection(
        [physics_visa_recent, physics_visa_old],
        attribute_names: %w[name],
      )
    end
  end
end
