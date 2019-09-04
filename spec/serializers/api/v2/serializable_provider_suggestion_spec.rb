require 'rails_helper'

describe API::V2::SerializableProviderSuggestion do
  let(:provider) { create(:provider) }
  let(:resource) { described_class.new(object: provider) }
  let(:serialized_provider) { JSON.parse(resource.as_jsonapi.to_json) }

  it 'sets type to providers' do
    expect(resource.jsonapi_type).to eq :provider
  end

  it 'serializes the name' do
    expect(serialized_provider).to have_attribute(:provider_name).with_value(provider.provider_name)
  end

  it 'serializes the provider code' do
    expect(serialized_provider).to have_attribute(:provider_code).with_value(provider.provider_code)
  end
end
