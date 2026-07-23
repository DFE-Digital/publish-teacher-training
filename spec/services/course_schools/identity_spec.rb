# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseSchools::Identity do
  let(:remodel_cycle_year) { 2026 }
  let(:gias_school) { create(:gias_school, urn: "123456") }
  let(:site_uuid) { Faker::Internet.uuid }
  let(:provider_school_uuid) { Faker::Internet.uuid }

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
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

    it "still resolves legacy site IDs for old add-course paths" do
      identity = described_class.new(provider:, course:)

      expect(identity.school_records_for(school_uuids: [site.id])).to eq([site])
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

    it "does not resolve a diverged legacy site UUID" do
      identity = described_class.new(provider:, course:)

      expect(identity.school_records_for(school_uuids: [site_uuid])).to be_empty
    end
  end
end
