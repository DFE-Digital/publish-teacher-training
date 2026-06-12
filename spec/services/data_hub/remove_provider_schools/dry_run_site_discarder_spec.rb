require "rails_helper"

RSpec.describe DataHub::RemoveProviderSchools::DryRunSiteDiscarder do
  let(:provider) { create(:provider) }
  let(:site) { create(:site, provider:, urn: "99999", location_name: "Remove School") }

  it "reports the site without discarding it", :aggregate_failures do
    result = described_class.new(site:).call

    expect(result.site_id).to eq site.id
    expect(result.urn).to eq "99999"
    expect(result.location_name).to eq "Remove School"
    expect(site.reload).not_to be_discarded
  end
end
