require 'rails_helper'

describe API::V2::SerializableSiteStatus do
  let(:site_status) { create :site_status }
  let(:resource) { API::V2::SerializableSiteStatus.new object: site_status }

  it 'sets type to site_statuses' do
    expect(resource.jsonapi_type).to eq :site_statuses
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type 'site_statuses' }
end
