require 'rails_helper'

describe API::V2::SerializableSite do
  let(:site)     { create :site }
  let(:resource) { API::V2::SerializableSite.new object: site }

  it 'sets type to sites' do
    expect(resource.jsonapi_type).to eq :sites
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type 'sites' }
  it { should have_attribute(:location_name).with_value(site.location_name) }
  it { should have_attribute(:address1).with_value(site.address1) }
  it { should have_attribute(:address2).with_value(site.address2) }
  it { should have_attribute(:address3).with_value(site.address3) }
  it { should have_attribute(:address4).with_value(site.address4) }
  it { should have_attribute(:postcode).with_value(site.postcode) }
  it { should have_attribute(:region_code).with_value(site.region_code) }
  it { should have_attribute(:recruitment_cycle_year).with_value(site.recruitment_cycle.year) }
end
