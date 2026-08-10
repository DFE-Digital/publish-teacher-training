# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rollover::Schools::LegacyProviderCopier do
  subject(:copy_sites) { described_class.new(site_copier: Sites::CopyToProviderService.new).execute(provider:, new_provider:) }

  let(:provider) { create(:provider) }
  let(:new_provider) { create(:provider, recruitment_cycle: create(:recruitment_cycle, :next)) }
  let!(:site) { create(:site, :with_gias_school, provider:, code: "S") }

  it "copies school sites to the new provider" do
    expect { copy_sites }.to change(new_provider.sites, :count).from(0).to(1)

    expect(new_provider.sites.pluck(:code, :urn)).to contain_exactly([site.code, site.urn])
  end

  it "returns the number of sites it created" do
    expect(copy_sites).to eq(copied: 1, skipped: [], already_present: [])
  end

  it "does not copy a site whose GIAS record has closed" do
    create(:site, provider:, code: "Z", urn: create(:gias_school, :closed).urn)

    copy_sites

    expect(new_provider.sites.pluck(:code)).to contain_exactly(site.code)
  end

  describe "idempotency" do
    it "does not copy a site that has already been rolled over" do
      copy_sites

      expect { described_class.new(site_copier: Sites::CopyToProviderService.new).execute(provider:, new_provider:) }
        .not_to change(new_provider.sites, :count)
    end

    it "reports the sites that were already present rather than counting them as copied" do
      copy_sites

      result = described_class.new(site_copier: Sites::CopyToProviderService.new).execute(provider:, new_provider:)

      expect(result).to eq(copied: 0, skipped: [], already_present: [site.code])
    end

    it "matches on URN rather than site code" do
      create(:site, provider: new_provider, urn: site.urn, code: "X")

      expect { copy_sites }.not_to change(new_provider.sites, :count)
    end

    it "copies a source site whose URN is not yet on the new provider" do
      create(:site, :with_gias_school, provider: new_provider, code: site.code)

      expect { copy_sites }.to change(new_provider.sites, :count).by(1)
    end

    it "copies a main site only once" do
      main_site = create(:site, :main_site, provider:)

      copy_sites
      described_class.new(site_copier: Sites::CopyToProviderService.new).execute(provider:, new_provider:)

      expect(new_provider.sites.where(code: main_site.code).count).to eq(1)
    end

    it "does not skip a URN-less source site because an unrelated site holds its code" do
      main_site = create(:site, :main_site, provider:)
      create(:site, :with_gias_school, provider: new_provider, code: main_site.code)

      copy_sites

      expect(new_provider.sites.where(code: main_site.code).count).to eq(2)
    end

    it "copies a site again once the rolled over copy has been discarded" do
      copy_sites
      new_provider.sites.sole.discard

      expect { described_class.new(site_copier: Sites::CopyToProviderService.new).execute(provider:, new_provider:) }
        .to change(new_provider.sites, :count).from(0).to(1)
    end
  end
end
