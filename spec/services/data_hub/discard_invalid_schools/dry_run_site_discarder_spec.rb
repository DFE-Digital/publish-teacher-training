require "rails_helper"

RSpec.describe DataHub::DiscardInvalidSchools::DryRunSiteDiscarder do
  let(:provider) { create(:provider) }

  context "with nil URN" do
    let(:site) { create(:site, provider:, urn: nil) }

    it "returns result with reason :no_urn without discarding" do
      result = described_class.new(site:).call
      expect(result.reason).to eq :no_urn
      expect(Site.discarded.find_by(id: site.id)).to be_nil
    end
  end

  context "with non-matching URN" do
    let(:site) { create(:site, provider:, urn: "12345") }

    it "returns result with reason :invalid_urn without discarding" do
      result = described_class.new(site:).call
      expect(result.reason).to eq :invalid_urn
      expect(Site.discarded.find_by(id: site.id)).to be_nil
    end
  end
end
