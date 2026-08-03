# frozen_string_literal: true

require "rails_helper"

describe Schools::UuidResolver do
  subject(:resolution) { described_class.call(provider:, uuids:, log_tag: "TestCaller") }

  let(:provider) { create(:provider, sites: [build(:site), build(:site)]) }
  let(:first_school) { provider.sites.first }
  let(:second_school) { provider.sites.second }

  context "when every uuid belongs to the provider" do
    let(:uuids) { [second_school.uuid, first_school.uuid] }

    it "returns the schools in the order they were submitted" do
      expect(resolution.schools.map(&:id)).to eq([second_school.id, first_school.id])
      expect(resolution.unrecognised_uuids).to be_empty
      expect(resolution).not_to be_unrecognised
    end

    it "does not log" do
      expect(Rails.logger).not_to receive(:warn)

      resolution
    end
  end

  context "when a uuid does not belong to the provider" do
    let(:other_providers_school) { create(:site, provider: create(:provider)) }
    let(:uuids) { [first_school.uuid, other_providers_school.uuid] }

    it "resolves the rest and reports the unrecognised uuid" do
      allow(Rails.logger).to receive(:warn)

      expect(resolution.schools.map(&:id)).to eq([first_school.id])
      expect(resolution.unrecognised_uuids).to eq([other_providers_school.uuid])
      expect(resolution).to be_unrecognised
    end

    it "logs the unrecognised uuid against the caller's tag" do
      expect(Rails.logger).to receive(:warn).with(
        "[TestCaller] unrecognised school UUIDs for provider=#{provider.id}: #{other_providers_school.uuid}",
      )

      resolution
    end
  end

  context "when no uuid resolves" do
    let(:unrecognised_uuid) { SecureRandom.uuid }
    let(:uuids) { [unrecognised_uuid] }

    it "returns no schools and reports the uuid" do
      allow(Rails.logger).to receive(:warn)

      expect(resolution.schools).to be_empty
      expect(resolution.unrecognised_uuids).to eq([unrecognised_uuid])
    end
  end

  context "when a school has been discarded" do
    let(:uuids) { [first_school.uuid] }

    before { first_school.discard }

    it "treats it as unrecognised" do
      allow(Rails.logger).to receive(:warn)

      expect(resolution.schools).to be_empty
      expect(resolution.unrecognised_uuids).to eq([first_school.uuid])
    end
  end

  context "when nothing was submitted" do
    let(:uuids) { ["", nil] }

    it "returns an empty result without querying or logging" do
      expect(Rails.logger).not_to receive(:warn)

      expect(resolution.schools).to be_empty
      expect(resolution.unrecognised_uuids).to be_empty
      expect(resolution).not_to be_unrecognised
    end
  end
end
