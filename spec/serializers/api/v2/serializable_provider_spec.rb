require 'rails_helper'

describe API::V2::SerializableProvider do
  let(:accrediting_provider) { create(:provider, :accredited_body) }
  let(:course) { create(:course, accrediting_provider: accrediting_provider) }
  let(:provider) { create :provider, courses: [course] }
  let(:resource) { described_class.new object: provider }

  it 'sets type to providers' do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type 'providers' }
  it { should have_attribute(:provider_code).with_value(provider.provider_code) }
  it { should have_attribute(:provider_name).with_value(provider.provider_name) }
  it { should have_attribute(:accredited_body?).with_value(false) }
  it { should have_attribute(:can_add_more_sites?).with_value(true) }
  it { should have_attribute(:recruitment_cycle_year).with_value(provider.recruitment_cycle.year) }
  it do
    should have_attribute(:accredited_bodies).with_value([
      {
        'provider_name' => accrediting_provider.provider_name,
        'provider_code' => accrediting_provider.provider_code,
        'description' => ''
      }
    ])
  end
end
