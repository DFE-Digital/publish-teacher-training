require 'rails_helper'

describe "Provider Factory" do
  let(:provider) { create(:provider) }

  it "created provider" do
    expect(provider).to be_instance_of(Provider)
    expect(provider).to be_valid
  end

  it "creates a provider with enrichments" do
    expect(provider.enrichments.count).to eq 1
    expect(provider.enrichments.first).to be_instance_of(ProviderEnrichment)
  end
end
