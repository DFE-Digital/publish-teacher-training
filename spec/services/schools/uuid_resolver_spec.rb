# frozen_string_literal: true

require "rails_helper"

describe Schools::UuidResolver do
  subject(:resolver) { described_class.new(provider:, uuids:, log_tag: "TestCaller") }

  let(:provider) { create(:provider) }

  let!(:first_school) { create(:provider_school, provider:) }
  let!(:second_school) { create(:provider_school, provider:) }

  context "when every uuid belongs to the provider" do
    let(:uuids) { [second_school.uuid, first_school.uuid] }

    it "returns the schools in the order they were submitted" do
      expect(resolver.schools.map(&:id)).to eq([second_school.id, first_school.id])
      expect(resolver.unrecognised_uuids).to be_empty
      expect(resolver).not_to be_unrecognised
    end

    it "does not log" do
      expect(Rails.logger).not_to receive(:warn)

      resolver.schools
    end
  end

  context "when a uuid does not belong to the provider" do
    let(:other_providers_school) { create(:provider_school) }
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

  context "when nothing was submitted" do
    let(:uuids) { ["", nil] }

    it "resolves nothing without logging" do
      expect(Rails.logger).not_to receive(:warn)

      expect(resolver.schools).to be_empty
      expect(resolver.unrecognised_uuids).to be_empty
      expect(resolver).not_to be_unrecognised
    end
  end
end
