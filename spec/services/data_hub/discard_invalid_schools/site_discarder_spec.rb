require "rails_helper"

RSpec.describe DataHub::DiscardInvalidSchools::SiteDiscarder do
  let(:urn) { "12345" }
  let(:provider) { create(:provider) }

  context "for site with missing URN" do
    let(:site) { create(:site, provider:, urn: nil) }

    it "returns reason :no_urn and discards site", :aggregate_failures do
      result = described_class.new(site:).call

      expect(result.site_id).to eq site.id
      expect(result.reason).to eq :no_urn
      expect(site.reload).to be_discarded
      expect(site.reload.discarded_via_script).to be true
    end
  end

  context "for site with invalid URN" do
    let(:site) { create(:site, provider:, urn:) }

    it "returns reason :invalid_urn and discards site" do
      result = described_class.new(site:).call

      expect(result.reason).to eq :invalid_urn
      expect(site.reload).to be_discarded
    end
  end
end
