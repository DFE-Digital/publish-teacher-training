require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { create(:provider) }

  describe 'associations' do
    it { should have_many(:sites) }
  end

  describe '#address' do
    it "returns attributes of the provider" do
      provider = create(:provider, enrichments: [])
      expect(provider.address).to eq provider.attributes
    end

    context "provider has enrichments" do
      it "returns json_data from the last enrichment" do
        enrichment = build(:provider_enrichment)
        provider = create(:provider, enrichments: [enrichment])

        expect(provider.address).to eq(
          "address1" => enrichment.json_data["Address1"],
          "address2" => enrichment.json_data["Address2"],
          "address3" => enrichment.json_data["Address3"],
          "address4" => enrichment.json_data["Address4"],
          "postcode" => enrichment.json_data["Postcode"]
        )
      end
    end
  end

  describe '#address1' do
    it "returns address1 of the address" do
      provider = create(:provider)
      expect(provider.address1).to eq provider.address["address1"]
    end
  end

  describe '#address2' do
    it "returns address2 of the address" do
      provider = create(:provider)
      expect(provider.address2).to eq provider.address["address2"]
    end
  end

  describe '#address3' do
    it "returns address3 of the address" do
      provider = create(:provider)
      expect(provider.address3).to eq provider.address["address3"]
    end
  end

  describe '#address4' do
    it "returns address4 of the address" do
      provider = create(:provider)
      expect(provider.address4).to eq provider.address["address4"]
    end
  end

  describe '#postcode' do
    it "returns postcode of the address" do
      provider = create(:provider)
      expect(provider.postcode).to eq provider.address["postcode"]
    end
  end
end
