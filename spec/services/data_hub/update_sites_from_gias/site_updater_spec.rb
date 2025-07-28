require "rails_helper"

RSpec.describe DataHub::UpdateSitesFromGias::SiteUpdater do
  subject(:updater) { described_class.new(site: site, gias_school: gias_school) }

  let(:site_attrs) do
    {
      location_name: "Broadway Academy",
      address1: "123 Main St",
      address2: "Suite 2",
      address3: "Old Block",
      town: "Birmingham",
      address4: "West Midlands",
      postcode: "B20 3DP",
      latitude: 52.12345,
      longitude: -1.98765,
    }
  end
  let!(:site) { create(:site, site_attrs) }
  let(:gias_school) { gias_hash_for(site_attrs, gias_overrides) }
  let(:gias_overrides) { {} }

  def gias_hash_for(site_hash, overrides = {})
    {
      name: site_hash[:location_name],
      address1: site_hash[:address1],
      address2: site_hash[:address2],
      address3: site_hash[:address3],
      town: site_hash[:town],
      county: site_hash[:address4],
      postcode: site_hash[:postcode],
      latitude: site_hash[:latitude],
      longitude: site_hash[:longitude],
    }.merge(overrides)
  end

  context "when some fields are different" do
    let(:gias_overrides) do
      {
        address2: "Suite 2B",
        address3: "Old Block Renamed",
      }
    end

    it "detects changed fields and only updates those" do
      result = updater.call

      expect(result.site_id).to eq(site.id)
      expect(result.changes.keys).to match_array(%i[address2 address3])
      expect(result.changes).to eq(
        address2: { before: "Suite 2", after: "Suite 2B" },
        address3: { before: "Old Block", after: "Old Block Renamed" },
      )

      site.reload
      expect(site.address2).to eq "Suite 2B"
      expect(site.address3).to eq "Old Block Renamed"
      # unchanged fields remain
      expect(site.location_name).to eq "Broadway Academy"
    end
  end

  context "when all fields are identical, after normalization" do
    let(:gias_overrides) do
      {
        name: "broadway academy ",
        address1: "123   Main St",
        address2: "Suite 2",
        address3: "Old Block",
        town: "Birmingham",
        county: "WEST MIDLANDS",
        postcode: " B20   3dp",
        latitude: 52.12345000,
        longitude: -1.9876500,
      }
    end

    it "does not update anything if values equivalent" do
      expect { updater.call }.not_to(change { site.reload.updated_at })
      expect(updater.call.changes).to eq({})
    end
  end

  context "when only latitude or longitude differ by < 0.00001" do
    let(:gias_overrides) { { latitude: 52.123451, longitude: -1.987649 } }

    it "treats as unchanged (due to epsilon threshold)" do
      expect(updater.call.changes).to eq({})
    end
  end

  context "when latitude or longitude differ by > 0.00001" do
    let(:gias_overrides) { { latitude: 52.12400, longitude: -2.00001 } }

    it "detects as changed" do
      result = updater.call
      expect(result.changes.keys).to match_array(%i[latitude longitude])
      expect(result.changes[:latitude][:after]).to eq(52.12400)
      expect(result.changes[:longitude][:after]).to eq(-2.00001)
    end
  end

  context "when site has nil and gias has value" do
    let!(:site) { create(:site, site_attrs.merge(address2: nil)) }
    let(:gias_overrides) { { address2: "Suite 2B" } }

    it "detects nil vs value as a change" do
      result = updater.call

      expect(result.changes.keys).to include(:address2)
      expect(result.changes[:address2][:before]).to be_nil
      expect(result.changes[:address2][:after]).to eq("Suite 2B")
    end
  end

  context "when gias_postcode differs only by internal spaces and casing" do
    let!(:site) { create(:site, site_attrs.merge(postcode: "B20 3DP")) }
    let(:gias_overrides) { { postcode: " b20 3dp " } }

    it "treats postcodes as the same (normalization tested)" do
      expect(updater.call.changes).not_to have_key(:postcode)
    end
  end

  context "when gias has blank string and site has nil" do
    let!(:site) { create(:site, site_attrs.merge(address4: nil)) }
    let(:gias_overrides) { { county: "" } }

    it "does not treat nil and blank as a difference after normalization" do
      expect(updater.call.changes).not_to have_key(:address4)
    end
  end
end
