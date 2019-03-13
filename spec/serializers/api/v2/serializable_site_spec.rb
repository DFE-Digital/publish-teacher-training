require 'rails_helper'

describe API::V2::SerializableSite do
  let(:site)     { create :site }
  let(:resource) { API::V2::SerializableSite.new object: site }

  it 'sets type to sites' do
    expect(resource.jsonapi_type).to eq :sites
  end

  subject { resource.as_jsonapi.to_json }

  it { should be_json.with_content(type: 'sites') }
end
