# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseSchools::Identity do
  let(:remodel_cycle_year) { 2026 }
  let(:gias_school) { create(:gias_school, urn: "123456") }
  let(:site_uuid) { Faker::Internet.uuid }
  let(:provider_school_uuid) { Faker::Internet.uuid }
  let(:unknown_school_uuid) { Faker::Internet.uuid }

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
  end

  context "when the provider is before the schools remodel cycle" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year - 1) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let(:course) { create(:course, provider:) }
    let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }

    before do
      create(:site_status, course:, site:)
    end

    it "uses legacy site records and site UUIDs" do
      identity = described_class.new(provider:, course:)

      expect(identity.available_schools).to contain_exactly(site)
      expect(identity.current_school_uuids).to eq([site_uuid])
      expect(identity.school_records_for(school_uuids: [site_uuid])).to eq([site])
    end

    it "does not load all available schools before they are needed" do
      identity = described_class.new(provider:, course:)
      available_schools = identity.available_schools

      expect(available_schools).to be_a(ActiveRecord::Relation)
      expect(available_schools).not_to be_loaded
      expect(identity.available_schools_count).to eq(1)
      expect(available_schools).not_to be_loaded
    end
  end

  context "when the provider is in the schools remodel cycle" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let(:course) { create(:course, provider:) }
    let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }

    before do
      create(:site_status, course:, site:)
    end

    it "uses legacy site records and site UUIDs" do
      identity = described_class.new(provider:, course:)

      expect(identity.available_schools).to contain_exactly(site)
      expect(identity.current_school_uuids).to eq([site_uuid])
      expect(identity.school_records_for(school_uuids: [site_uuid])).to eq([site])
    end

    it "rejects an unknown legacy site UUID" do
      identity = described_class.new(provider:, course:)

      expect { identity.school_records_for(school_uuids: [unknown_school_uuid]) }
        .to raise_error(ArgumentError, /Could not resolve school UUIDs/)
    end

    it "rejects a legacy site belonging to another provider" do
      other_provider = create(:provider, recruitment_cycle:)
      other_site = create(:site, provider: other_provider, uuid: unknown_school_uuid)
      identity = described_class.new(provider:, course:)

      expect { identity.school_records_for(school_uuids: [other_site.uuid]) }
        .to raise_error(ArgumentError, /Could not resolve school UUIDs/)
    end

    it "rejects a mixture of valid and unknown UUIDs" do
      identity = described_class.new(provider:, course:)

      expect { identity.school_records_for(school_uuids: [site_uuid, unknown_school_uuid]) }
        .to raise_error(ArgumentError, /Could not resolve school UUIDs/)
    end

    it "rejects legacy site IDs" do
      identity = described_class.new(provider:, course:)

      expect { identity.school_records_for(school_uuids: [site.id]) }
        .to raise_error(ArgumentError, /School UUIDs must be valid UUIDs/)
    end

    it "deduplicates duplicate UUIDs" do
      identity = described_class.new(provider:, course:)

      expect(identity.school_records_for(school_uuids: [site_uuid, site_uuid])).to eq([site])
    end
  end

  context "when the provider is after the schools remodel cycle" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year + 1) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let(:course) { create(:course, provider:) }
    let!(:legacy_site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }
    let!(:provider_school) do
      create(:provider_school, provider:, gias_school:, site_code: legacy_site.code, uuid: provider_school_uuid)
    end

    before do
      create(:course_school, course:, provider_school:, gias_school:)
    end

    it "uses provider school records and provider school UUIDs" do
      identity = described_class.new(provider:, course:)

      expect(identity.available_schools).to contain_exactly(provider_school)
      expect(identity.current_school_uuids).to eq([provider_school_uuid])
      expect(identity.school_records_for(school_uuids: [provider_school_uuid])).to eq([provider_school])
    end

    it "rejects an unknown provider school UUID" do
      identity = described_class.new(provider:, course:)

      expect { identity.school_records_for(school_uuids: [unknown_school_uuid]) }
        .to raise_error(ArgumentError, /Could not resolve school UUIDs/)
    end

    it "rejects a provider school belonging to another provider" do
      other_provider = create(:provider, recruitment_cycle:)
      other_provider_school = create(:provider_school, provider: other_provider, uuid: unknown_school_uuid)
      identity = described_class.new(provider:, course:)

      expect { identity.school_records_for(school_uuids: [other_provider_school.uuid]) }
        .to raise_error(ArgumentError, /Could not resolve school UUIDs/)
    end

    it "does not resolve a diverged legacy site UUID" do
      identity = described_class.new(provider:, course:)

      expect { identity.school_records_for(school_uuids: [site_uuid]) }
        .to raise_error(ArgumentError, /Could not resolve school UUIDs/)
    end

    it "rejects legacy site IDs" do
      identity = described_class.new(provider:, course:)

      expect { identity.school_records_for(school_uuids: [legacy_site.id]) }
        .to raise_error(ArgumentError, /School UUIDs must be valid UUIDs/)
    end

    it "deduplicates duplicate UUIDs" do
      identity = described_class.new(provider:, course:)

      expect(identity.school_records_for(school_uuids: [provider_school_uuid, provider_school_uuid])).to eq([provider_school])
    end
  end

  context "when initialized without a course" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let!(:site) { create(:site, provider:) }

    it "supports provider-only school lists" do
      identity = described_class.new(provider:)

      expect(identity.available_schools).to contain_exactly(site)
    end

    it "raises a descriptive error for course-specific school UUIDs" do
      identity = described_class.new(provider:)

      expect { identity.current_school_uuids }
        .to raise_error(ArgumentError, /requires a course for current_school_uuids/)
    end
  end
end
