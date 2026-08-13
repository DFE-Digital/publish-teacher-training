# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderSchools::SyncLegacySiteUuids do
  subject(:sync_uuids) { described_class.call(provider:) }

  let(:provider) { create(:provider) }
  let(:gias_school) { create(:gias_school, :open, urn: "123456") }
  let!(:legacy_site) { create(:site, provider:, code: "A", urn: gias_school.urn) }
  let!(:provider_school) do
    create(
      :provider_school,
      provider:,
      gias_school:,
      site_code: legacy_site.code,
      uuid: SecureRandom.uuid,
    )
  end

  it "rewrites the provider school UUID to match the legacy site UUID" do
    expect { sync_uuids }
      .to change { provider_school.reload.uuid }
      .to(legacy_site.uuid)
  end

  it "does not rewrite an already aligned provider school UUID" do
    provider_school.update!(uuid: legacy_site.uuid)

    expect { sync_uuids }
      .not_to(change { provider_school.reload.updated_at })
  end

  it "matches by provider, site code and GIAS URN" do
    other_provider = create(:provider)
    create(:site, provider: other_provider, code: legacy_site.code, urn: gias_school.urn)

    sync_uuids

    expect(provider_school.reload.uuid).to eq(legacy_site.uuid)
  end

  context "when duplicate legacy sites match" do
    let!(:duplicate_site) do
      build(:site, provider:, code: legacy_site.code, urn: gias_school.urn).tap do |site|
        site.save!(validate: false)
      end
    end

    it "uses one of the matching legacy site UUIDs" do
      sync_uuids

      expect([legacy_site.uuid, duplicate_site.uuid]).to include(provider_school.reload.uuid)
    end
  end

  context "when no matching legacy site exists" do
    before { legacy_site.destroy! }

    it "raises a mismatch error" do
      expect { sync_uuids }
        .to raise_error(
          described_class::LegacySiteMismatchError,
          /expected at least one legacy site for provider=#{provider.id}/,
        )
    end
  end
end
