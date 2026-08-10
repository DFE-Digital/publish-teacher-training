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
  let!(:legacy_site) { create(:site, :with_gias_school, provider:, code: "S") }
  let!(:provider_school) { create(:provider_school, provider:, site_code: "B") }

  it "copies both legacy Site and new Provider::School records" do
    expect { copy_schools }
      .to change(new_provider.sites, :count).by(1)
      .and change(new_provider.schools, :count).by(1)

    expect(new_provider.sites.pluck(:code)).to contain_exactly(legacy_site.code)
    expect(new_provider.schools.pluck(:gias_school_id, :site_code)).to contain_exactly(
      [provider_school.gias_school_id, provider_school.site_code],
    )
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
