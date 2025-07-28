require "rails_helper"

RSpec.describe DataHub::UpdateSitesFromGias::SchoolsGiasDiffQuery do
  subject(:diff_records) { described_class.new(recruitment_cycle: recruitment_cycle).records_to_update }

  let(:recruitment_cycle) { RecruitmentCycle.current }
  let(:provider) { create(:provider, recruitment_cycle: recruitment_cycle) }

  def site_and_gias_pairs(overrides_site: {}, overrides_gias: {})
    urn = "1#{rand(10_000..99_999)}"
    base_name = overrides_site[:location_name] || overrides_gias[:name] || "Test School #{urn}"
    site = create(
      :site,
      provider: provider,
      urn: urn,
      location_name: base_name,
      address1: "Main Rd",
      address2: "Block A",
      address3: "Old Wing",
      town: "Testtown",
      address4: "Countyshire",
      postcode: "BN1 1AA",
      latitude: 12.34,
      longitude: 56.78,
      **overrides_site,
    )
    gias = create(
      :gias_school,
      urn: urn,
      name: site.location_name,
      address1: site.address1,
      address2: site.address2,
      address3: site.address3,
      town: site.town,
      county: site.address4,
      postcode: site.postcode,
      latitude: site.latitude,
      longitude: site.longitude,
      **overrides_gias,
    )
    [site, gias]
  end

  it "returns empty when there are no field differences" do
    _, _gias = site_and_gias_pairs
    expect(diff_records.pluck(:urn)).to eq([])
  end

  it "returns the site when only location_name is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { location_name: "AAA" },
      overrides_gias: { name: "BBB" },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "returns the site when only address1 is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { address1: "Apples Lane" },
      overrides_gias: { address1: "Oranges Lane" },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "returns the site when only address2 is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { address2: "Floor 7" },
      overrides_gias: { address2: "Floor 8" },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "returns the site when only address3 is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { address3: "North Block" },
      overrides_gias: { address3: "South Block" },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "returns the site when only town is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { town: "Northville" },
      overrides_gias: { town: "Southville" },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "returns the site when only address4/county is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { address4: "County A" },
      overrides_gias: { county: "County B" },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "returns the site when only postcode is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { postcode: "ZZ91 1ZZ" },
      overrides_gias: { postcode: "ZZ91 2YY" },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "normalizes postcodes so 'BN1 1AA' == ' bn1 1aa '" do
    _, _gias = site_and_gias_pairs(
      overrides_site: { postcode: "BN1 1AA" },
      overrides_gias: { postcode: " bn1   1aa " },
    )
    expect(diff_records.pluck(:urn)).to eq([])
  end

  it "returns the site when only latitude is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { latitude: 11.11 },
      overrides_gias: { latitude: 12.12 },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "returns the site when only longitude is different" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { longitude: 99.99 },
      overrides_gias: { longitude: 88.88 },
    )
    expect(diff_records.pluck(:urn)).to eq([site.urn])
  end

  it "ignores sites in other recruitment cycles" do
    other_cycle = create(:recruitment_cycle, year: 2031)
    other_provider = create(:provider, recruitment_cycle: other_cycle)
    site = create(:site, provider: other_provider, urn: "99912", location_name: "OtherCycle")
    create(:gias_school, urn: "99912", name: "Different")
    expect(diff_records.pluck(:urn)).not_to include(site.urn)
  end

  it "ignores sites with no joined GIAS record" do
    site = create(:site, provider: provider, urn: "12345", location_name: "OrphanSite")
    expect(diff_records.pluck(:urn)).not_to include(site.urn)
  end

  it "returns only unique sites with one field difference" do
    site1, _gias1 = site_and_gias_pairs(
      overrides_site: { address1: "AA" },
      overrides_gias: { address1: "BB" },
    )
    site2, _gias2 = site_and_gias_pairs(
      overrides_site: { address2: "CC" },
      overrides_gias: { address2: "DD" },
    )
    urns = diff_records.pluck(:urn)
    expect(urns.uniq.size).to eq(urns.size)
    expect(urns).to include(site1.urn, site2.urn)
  end

  it "yields GIAS fields as select aliases for a site with a difference" do
    site, _gias = site_and_gias_pairs(
      overrides_site: { latitude: 99.01 },
      overrides_gias: { latitude: 44.44, address1: "FooAddr" },
    )
    record = diff_records.find_by(urn: site.urn)
    expect(record.gias_latitude).to eq(44.44)
    expect(record.gias_address1).to eq("FooAddr")
  end
end
