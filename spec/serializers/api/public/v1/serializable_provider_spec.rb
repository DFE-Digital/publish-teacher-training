require "rails_helper"

describe API::Public::V1::SerializableProvider do
  let(:provider) { create :provider }
  let(:resource) { described_class.new object: provider }

  it "sets type to providers" do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { is_expected.to have_type "providers" }

  it { is_expected.to have_attribute(:postcode).with_value(provider.postcode) }
  it { is_expected.to have_attribute(:provider_type).with_value(provider.provider_type) }
  it { is_expected.to have_attribute(:region_code).with_value(provider.region_code) }
  it { is_expected.to have_attribute(:train_with_disability).with_value(provider.train_with_disability) }
  it { is_expected.to have_attribute(:train_with_us).with_value(provider.train_with_us) }
  it { is_expected.to have_attribute(:website).with_value(provider.website) }

  it { is_expected.to have_attribute(:accredited_body).with_value(provider.accredited_body?) }
  it { is_expected.to have_attribute(:changed_at).with_value(provider.changed_at.iso8601) }
  it { is_expected.to have_attribute(:city).with_value(provider.address3) }
  it { is_expected.to have_attribute(:code).with_value(provider.provider_code) }
  it { is_expected.to have_attribute(:county).with_value(provider.address4) }
  it { is_expected.to have_attribute(:created_at).with_value(provider.created_at.iso8601) }
  it { is_expected.to have_attribute(:name).with_value(provider.provider_name) }
  it { is_expected.to have_attribute(:street_address_1).with_value(provider.address1) }
  it { is_expected.to have_attribute(:street_address_2).with_value(provider.address2) }
  it { is_expected.to have_attribute(:latitude).with_value(provider.latitude) }
  it { is_expected.to have_attribute(:longitude).with_value(provider.longitude) }
  it { is_expected.to have_attribute(:telephone).with_value(provider.telephone) }
  it { is_expected.to have_attribute(:email).with_value(provider.email) }
  it { is_expected.to have_attribute(:can_sponsor_skilled_worker_visa).with_value(provider.can_sponsor_skilled_worker_visa) }
  it { is_expected.to have_attribute(:can_sponsor_student_visa).with_value(provider.can_sponsor_student_visa) }
end
