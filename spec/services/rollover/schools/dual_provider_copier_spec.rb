# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rollover::Schools::DualProviderCopier do
  subject(:copy_schools) do
    described_class.new(
      legacy_copier: Rollover::Schools::LegacyProviderCopier.new(site_copier: Sites::CopyToProviderService.new),
      new_copier: Rollover::Schools::ProviderCopier.new,
    ).execute(provider:, new_provider:)
  end

  let(:provider) { create(:provider) }
  let(:new_provider) { create(:provider, recruitment_cycle: create(:recruitment_cycle, :next)) }
  let(:gias_school) { create(:gias_school, :open) }
  let!(:legacy_site) { create(:site, provider:, code: "S", urn: gias_school.urn) }
  let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: legacy_site.code) }

  it "copies both legacy Site and new Provider::School records" do
    expect { copy_schools }
      .to change(new_provider.sites, :count).by(1)
      .and change(new_provider.schools, :count).by(1)

    expect(new_provider.sites.pluck(:code)).to contain_exactly(legacy_site.code)
    expect(new_provider.schools.pluck(:gias_school_id, :site_code)).to contain_exactly(
      [provider_school.gias_school_id, provider_school.site_code],
    )
  end

  it "syncs the copied Provider::School UUID to the copied legacy Site UUID" do
    copy_schools

    copied_site = new_provider.sites.find_by!(code: legacy_site.code)
    copied_provider_school = new_provider.schools.find_by!(gias_school:, site_code: legacy_site.code)

    expect(copied_provider_school.uuid).to eq(copied_site.uuid)
  end

  it "returns the legacy result used by rollover reporting" do
    expect(copy_schools).to eq(copied: 1, skipped: [], already_present: [])
  end

  it "copies neither the legacy Site nor the Provider::School when the GIAS record has closed" do
    closed_gias_school = create(:gias_school, :closed)
    create(:site, provider:, code: "Z", urn: closed_gias_school.urn)
    create(:provider_school, provider:, gias_school: closed_gias_school, site_code: "Z")

    copy_schools

    expect(new_provider.sites.pluck(:code)).to contain_exactly(legacy_site.code)
    expect(new_provider.schools.pluck(:site_code)).to contain_exactly(provider_school.site_code)
  end
end
