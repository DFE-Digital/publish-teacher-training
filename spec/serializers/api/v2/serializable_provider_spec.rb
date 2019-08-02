require 'rails_helper'

describe API::V2::SerializableProvider do
  let(:provider) { create :provider, accrediting_provider: 'Y' }
  let(:resource) { described_class.new object: provider }

  it 'sets type to providers' do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type 'providers' }
  it { should have_attribute(:provider_code).with_value(provider.provider_code) }
  it { should have_attribute(:provider_name).with_value(provider.provider_name) }
  it { should have_attribute(:accredited_body?).with_value(true) }
  it { should have_attribute(:can_add_more_sites?).with_value(true) }
  it { should have_attribute(:recruitment_cycle_year).with_value(provider.recruitment_cycle.year) }
end
