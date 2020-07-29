require "rails_helper"

describe API::Public::V1::SerializableProvider do
  let(:provider) { create :provider }
  let(:resource) { described_class.new object: provider }

  it "sets type to providers" do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type "providers" }

  it { should have_attribute(:postcode).with_value(provider.postcode) }
  it { should have_attribute(:provider_type).with_value(provider.provider_type) }
  it { should have_attribute(:region_code).with_value(provider.region_code) }
  it { should have_attribute(:train_with_disability).with_value(provider.train_with_disability) }
  it { should have_attribute(:train_with_us).with_value(provider.train_with_us) }
  it { should have_attribute(:website).with_value(provider.website) }

  it { should have_attribute(:accredited_body).with_value(provider.accredited_body?) }
  it { should have_attribute(:changed_at).with_value(provider.changed_at.iso8601) }
  it { should have_attribute(:city).with_value(provider.address3) }
  it { should have_attribute(:code).with_value(provider.provider_code) }
  it { should have_attribute(:county).with_value(provider.address4) }
  it { should have_attribute(:created_at).with_value(provider.created_at.iso8601) }
  it { should have_attribute(:name).with_value(provider.provider_name) }
  it { should have_attribute(:recruitment_cycle_year).with_value(provider.recruitment_cycle.year) }
  it { should have_attribute(:street_address_1).with_value(provider.address1) }
  it { should have_attribute(:street_address_2).with_value(provider.address2) }
end
