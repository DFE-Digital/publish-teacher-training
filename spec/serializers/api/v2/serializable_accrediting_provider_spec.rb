require 'rails_helper'

describe API::V2::SerializableAccreditingProvider do
  let(:provider) { create :provider, accrediting_provider: 'Y' }
  let(:resource) { described_class.new object: provider }

  it 'sets type to providers' do
    expect(resource.jsonapi_type).to eq :accrediting_providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type 'accrediting_providers' }
  it { should have_attribute(:provider_code).with_value(provider.provider_code) }
  it { should have_attribute(:provider_name).with_value(provider.provider_name) }
end
