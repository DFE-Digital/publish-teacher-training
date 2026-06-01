require "rails_helper"

RSpec.describe DataHub::RemoveProviderSchools::SiteDiscarder do
  let(:provider) { create(:provider) }
  let(:site) { create(:site, provider:, urn: "99999", location_name: "Remove School") }

  it "discards the site and flags it as discarded via script", :aggregate_failures do
    result = described_class.new(site:).call

    expect(result.site_id).to eq site.id
    expect(result.urn).to eq "99999"
    expect(result.location_name).to eq "Remove School"
    expect(site.reload).to be_discarded
    expect(site.reload.discarded_via_script).to be true
  end
end
