require "rails_helper"

RSpec.describe DataHub::UpdateSitesFromGias::DryRunSiteUpdater do
  subject(:result) { described_class.new(site:, gias_school:).call }

  let(:site) { create(:site, location_name: "A", address1: "Old St", latitude: 1.23) }

  let(:gias_school) do
    {
      name: "A",
      address1: "New St",
      address2: site.address2,
      address3: site.address3,
      town: site.town,
      county: site.address4,
      postcode: site.postcode,
      latitude: 4.56,
      longitude: site.longitude,
    }
  end

  it "detects differences but does not update the site" do
    expect { result }.not_to(change { [site.reload.address1, site.reload.latitude] })

    expect(result.site_id).to eq(site.id)
    expect(result.changes.keys).to match_array(%i[address1 latitude])
    expect(result.changes[:address1]).to eq(before: "Old St", after: "New St")
    expect(result.changes[:latitude]).to eq(before: 1.23, after: 4.56)
  end

  it "returns no changes if values are identical (including normalization)" do
    gias = gias_school.merge(address1: "old st", latitude: 1.230001)
    updater = described_class.new(site:, gias_school: gias)
    expect(updater.call.changes).to eq({})
    expect(site.reload.address1).to eq("Old St")
  end
end
