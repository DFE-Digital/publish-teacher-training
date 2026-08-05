# frozen_string_literal: true

require "rails_helper"

describe Schools::UuidResolver do
  subject(:resolver) { described_class.new(provider:, uuids:, log_tag: "TestCaller") }

  let(:provider) { create(:provider) }

  # Sites are created with their Provider::School half, keyed by the same uuid,
  # which is the state the backfill leaves every provider in.
  let!(:first_site) { create(:site, :with_provider_school, provider:) }
  let!(:second_site) { create(:site, :with_provider_school, provider:) }

  let(:first_school) { provider.schools.find_by(uuid: first_site.uuid) }
  let(:second_school) { provider.schools.find_by(uuid: second_site.uuid) }

  context "when every uuid belongs to the provider" do
    let(:uuids) { [second_school.uuid, first_school.uuid] }

    it "returns the schools in the order they were submitted" do
      expect(resolver.schools.map(&:id)).to eq([second_school.id, first_school.id])
      expect(resolver.unrecognised_uuids).to be_empty
      expect(resolver).not_to be_unrecognised
    end

    it "returns the matching legacy sites in the order they were submitted" do
      expect(resolver.sites.map(&:id)).to eq([second_site.id, first_site.id])
    end

    it "does not log" do
      expect(Rails.logger).not_to receive(:warn)

      resolver.schools
    end
  end

  context "when a uuid does not belong to the provider" do
    let(:other_providers_school) { create(:site, :with_provider_school, provider: create(:provider)) }
    let(:uuids) { [first_school.uuid, other_providers_school.uuid] }

    it "resolves the rest and reports the unrecognised uuid" do
      allow(Rails.logger).to receive(:warn)

      expect(resolver.schools.map(&:id)).to eq([first_school.id])
      expect(resolver.unrecognised_uuids).to eq([other_providers_school.uuid])
      expect(resolver).to be_unrecognised
    end

    it "logs the unrecognised uuid against the caller's tag" do
      expect(Rails.logger).to receive(:warn).with(
        "[TestCaller] unrecognised school UUIDs for provider=#{provider.id}: #{other_providers_school.uuid}",
      )

      resolver.schools
    end

    # Callers read the resolution in whichever shape suits them, and some read
    # more than one. The provider is one submission short either way, so it is
    # one log line rather than one per reader.
    it "logs once however many times the resolution is read" do
      expect(Rails.logger).to receive(:warn).once

      resolver.schools
      resolver.sites
      resolver.unrecognised_uuids
    end

    it "logs when only the unrecognised uuids are read" do
      expect(Rails.logger).to receive(:warn).once

      resolver.unrecognised?
    end
  end

  context "when no uuid resolves" do
    let(:unrecognised_uuid) { SecureRandom.uuid }
    let(:uuids) { [unrecognised_uuid] }

    it "returns no schools and reports the uuid" do
      allow(Rails.logger).to receive(:warn)

      expect(resolver.schools).to be_empty
      expect(resolver.unrecognised_uuids).to eq([unrecognised_uuid])
    end
  end

  # Recognition is decided by Provider::School, so a site whose half of the
  # backfill is missing does not resolve, even though the site itself is there.
  context "when a site has no Provider::School" do
    let(:site_without_school) { create(:site, provider:) }
    let(:uuids) { [site_without_school.uuid] }

    it "treats it as unrecognised" do
      allow(Rails.logger).to receive(:warn)

      expect(resolver.schools).to be_empty
      expect(resolver.unrecognised_uuids).to eq([site_without_school.uuid])
    end
  end

  # Provider::School is hard-deleted on removal rather than discarded, so
  # discarding the legacy site on its own leaves the school resolvable.
  context "when the legacy site has been discarded" do
    let(:uuids) { [first_school.uuid] }

    before { first_site.discard }

    it "still resolves the school but drops the discarded site" do
      expect(resolver.schools.map(&:id)).to eq([first_school.id])
      expect(resolver).not_to be_unrecognised
      expect(resolver.sites).to be_empty
    end
  end

  context "when nothing was submitted" do
    let(:uuids) { ["", nil] }

    it "resolves nothing without logging" do
      expect(Rails.logger).not_to receive(:warn)

      expect(resolver.schools).to be_empty
      expect(resolver.sites).to be_empty
      expect(resolver.unrecognised_uuids).to be_empty
      expect(resolver).not_to be_unrecognised
    end
  end
end
