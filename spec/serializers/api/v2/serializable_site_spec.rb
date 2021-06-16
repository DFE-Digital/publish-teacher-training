require "rails_helper"

describe API::V2::SerializableSite do
  let(:site)     { create :site }
  let(:resource) { API::V2::SerializableSite.new object: site }

  it "sets type to sites" do
    expect(resource.jsonapi_type).to eq :sites
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { is_expected.to have_type "sites" }
  it { is_expected.to have_attribute(:location_name).with_value(site.location_name) }
  it { is_expected.to have_attribute(:address1).with_value(site.address1) }
  it { is_expected.to have_attribute(:address2).with_value(site.address2) }
  it { is_expected.to have_attribute(:address3).with_value(site.address3) }
  it { is_expected.to have_attribute(:address4).with_value(site.address4) }
  it { is_expected.to have_attribute(:postcode).with_value(site.postcode) }
  it { is_expected.to have_attribute(:region_code).with_value(site.region_code) }
  it { is_expected.to have_attribute(:travel_to_work_area).with_value(site.travel_to_work_area) }
  it { is_expected.to have_attribute(:london_borough).with_value(site.london_borough) }
  it { is_expected.to have_attribute(:recruitment_cycle_year).with_value(site.recruitment_cycle.year) }
end
