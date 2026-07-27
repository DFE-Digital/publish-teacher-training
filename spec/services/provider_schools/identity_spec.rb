# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderSchools::Identity do
  let(:remodel_cycle_year) { 2026 }
  let(:gias_school) { create(:gias_school, urn: "123456") }
  let(:site_uuid) { Faker::Internet.uuid }
  let(:provider_school_uuid) { Faker::Internet.uuid }

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
  end

  describe ".ordered_school_scope" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year - 1) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let!(:legacy_site) { create(:site, provider:, urn: "654321", code: "B") }
    let!(:provider_school) { create(:provider_school, provider:, gias_school:) }

    it "always returns provider schools and does not require a matching site" do
      expect(described_class.ordered_school_scope(provider:)).to contain_exactly(provider_school)
    end
  end

  describe "#school_for" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year - 1) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }
    let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site_uuid) }

    it "finds the provider school by uuid regardless of recruitment cycle" do
      expect(described_class.new(provider:).school_for(uuid: site_uuid)).to eq(provider_school)
    end

    it "finds the correct provider school when the same GIAS school is linked twice" do
      main_site = create(:site, :main_site, provider:, uuid: Faker::Internet.uuid)
      main_provider_school = create(:provider_school, provider:, gias_school:, site_code: "-", uuid: main_site.uuid)

      expect(described_class.new(provider:).school_for(uuid: main_site.uuid)).to eq(main_provider_school)
      expect(described_class.new(provider:).school_for(uuid: site_uuid)).to eq(provider_school)
    end

    it "raises when the provider school does not exist" do
      expect {
        described_class.new(provider:).school_for(uuid: provider_school_uuid)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
