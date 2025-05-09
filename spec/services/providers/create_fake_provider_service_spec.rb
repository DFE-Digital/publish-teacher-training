# frozen_string_literal: true

require "rails_helper"

RSpec.describe Providers::CreateFakeProviderService do
  let(:provider_type) { "scitt" }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:is_accredited_provider) { false }

  let(:service) do
    described_class.new(
      provider_name: "Fake Provider",
      provider_code: "123",
      provider_type:,
      recruitment_cycle:,
      is_accredited_provider:,
    )
  end

  it "creates providers" do
    expect {
      service.execute
    }.to change(Provider, :count).by(1).and \
      change(Organisation, :count).by(1).and \
        change(Site, :count).by(1)
  end

  context "a provider with that code already exists" do
    before do
      create(:provider, provider_code: "123", recruitment_cycle:)
    end

    it "does not complete" do
      expect(service.execute).not_to be(true)
      expect(service.errors).to eq ["Provider Fake Provider (123) already exists."]
    end
  end

  context "the requested provider is both a lead_school and an accredited_provider" do
    let(:provider_type) { "lead_school" }
    let(:is_accredited_provider) { true }

    it "does not complete" do
      expect(service.execute).not_to be(true)
      expect(service.errors).to eq ["Provider Fake Provider (123) cannot be both a lead school and an accredited provider."]
    end
  end

  context "is_accredited_provider is true" do
    let(:is_accredited_provider) { true }

    it "the created provider is an accredited_provider" do
      service.execute

      expect(Provider.last.accredited?).to be(true)
    end
  end

  context "is_accredited_provider is false" do
    let(:is_accredited_provider) { false }

    it "the created provider is an accredited_provider" do
      service.execute

      expect(Provider.last.accredited?).to be(false)
    end
  end
end
