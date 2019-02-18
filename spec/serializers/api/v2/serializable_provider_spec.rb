require 'rails_helper'

describe API::V2::SerializableProvider do
  let(:provider) { create :provider }
  let(:resource) { API::V2::SerializableProvider.new object: provider }

  it 'sets type to providers' do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { resource.as_jsonapi.to_json }

  it { should be_json.with_content(type: 'providers') }
end
