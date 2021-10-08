require "rails_helper"

describe API::V3::SerializableProvider do
  let(:provider) { create :provider }
  let(:resource) { described_class.new object: provider }

  it "sets type to providers" do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { is_expected.to have_type "providers" }
  it { is_expected.to have_attribute(:provider_code).with_value(provider.provider_code) }
  it { is_expected.to have_attribute(:provider_name).with_value(provider.provider_name) }
  it { is_expected.to have_attribute(:recruitment_cycle_year).with_value(provider.recruitment_cycle.year) }
  it { is_expected.to have_attribute(:address1).with_value(provider.address1) }
  it { is_expected.to have_attribute(:address2).with_value(provider.address2) }
  it { is_expected.to have_attribute(:address3).with_value(provider.address3) }
  it { is_expected.to have_attribute(:address4).with_value(provider.address4) }
  it { is_expected.to have_attribute(:postcode).with_value(provider.postcode) }
  it { is_expected.to have_attribute(:latitude).with_value(provider.latitude) }
  it { is_expected.to have_attribute(:longitude).with_value(provider.longitude) }
  it { is_expected.to have_attribute(:can_sponsor_student_visa).with_value(provider.can_sponsor_student_visa) }
  it { is_expected.to have_attribute(:can_sponsor_skilled_worker_visa).with_value(provider.can_sponsor_skilled_worker_visa) }
end
