require "rails_helper"

RSpec.describe Providers::CreateFakeProviderService do
  let(:provider_name) { "Fake Provider" }
  let(:provider_code) { "ABC" }
  let(:provider_type) { "scitt" }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:is_accredited_body) { false }

  let(:service) do
    described_class.new(
      provider_name: "Fake Provider",
      provider_code: "123",
      provider_type: "scitt",
      recruitment_cycle: recruitment_cycle,
      is_accredited_body: is_accredited_body,
    )
  end

  it "creates providers" do
    expect {
      service.execute
    }.to change { Provider.count }.by(1).and \
      change { Organisation.count }.by(1).and \
        change { Site.count }.by(1)
  end

  context "the provider code already exists" do
    before do
      create(:provider, provider_code: "123", recruitment_cycle: recruitment_cycle)
    end

    it "does not complete" do
      expect(service.execute).not_to be(true)
      expect(service.errors).to eq ["Provider Fake Provider (123) already exists."]
    end
  end

  context "the provider name already exists" do
    before do
      create(:provider, provider_name: "Fake Provider", recruitment_cycle: recruitment_cycle)
    end

    it "does not complete" do
      expect(service.execute).not_to be(true)
      expect(service.errors).to eq ["Provider Fake Provider (123) already exists."]
    end
  end

  context "is_accredited_body is true" do
    let(:is_accredited_body) { true }

    it "the created provider is an accredited_body" do
      service.execute

      expect(Provider.last.accredited_body?).to be(true)
    end
  end

  context "is_accredited_body is false" do
    let(:is_accredited_body) { false }

    it "the created provider is an accredited_body" do
      service.execute

      expect(Provider.last.accredited_body?).to be(false)
    end
  end
end
