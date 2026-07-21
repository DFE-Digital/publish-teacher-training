# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderSchools::Identity do
  let(:remodel_cycle_year) { 2026 }
  let(:gias_school) { create(:gias_school, urn: "123456") }
  let(:site_uuid) { "11111111-1111-4111-8111-111111111111" }
  let(:provider_school_uuid) { "22222222-2222-4222-8222-222222222222" }

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
  end

  describe ".uuid_for" do
    context "when the provider is in the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }

      before do
        create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: provider_school_uuid)
      end

      it "uses the legacy site uuid" do
        expect(described_class.uuid_for(site:)).to eq(site_uuid)
      end
    end

    context "when the provider is after the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year + 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }

      before do
        create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: provider_school_uuid)
      end

      it "uses the provider school uuid" do
        expect(described_class.uuid_for(site:)).to eq(provider_school_uuid)
      end
    end
  end

  describe ".visible_sites" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year + 1) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let!(:visible_site) { create(:site, provider:, urn: gias_school.urn, code: "A") }
    let!(:removed_site) { create(:site, provider:, urn: "654321", code: "B") }

    before do
      create(:provider_school, provider:, gias_school:, site_code: visible_site.code)
    end

    it "only returns sites with a matching provider school after the remodel cycle" do
      expect(described_class.visible_sites(provider:)).to contain_exactly(visible_site)
    end
  end

  describe "#site_for" do
    context "when the provider is in the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }

      it "finds the site by site uuid" do
        expect(described_class.new(provider:).site_for(uuid: site_uuid)).to eq(site)
      end
    end

    context "when the provider is after the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year + 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }

      before do
        create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: provider_school_uuid)
      end

      it "finds the legacy site via the provider school uuid" do
        expect(described_class.new(provider:).site_for(uuid: provider_school_uuid)).to eq(site)
      end
    end
  end
end
