require 'rails_helper'

describe API::V2::SerializableSite do
  let(:site)     { create :site }
  let(:resource) { API::V2::SerializableSite.new object: site }

  it 'sets type to sites' do
    expect(resource.jsonapi_type).to eq :sites
  end

  subject { resource.as_jsonapi.to_json }

  it { should be_json.with_content(type: 'sites') }
  it {
    should be_json.with_content(attributes: { location_name: site.location_name,
                                              address1: site.address1,
                                              address2: site.address2,
                                              address3: site.address3,
                                              address4: site.address4,
                                              postcode: site.postcode,
                                              region_code: site.region_code })
  }
end
