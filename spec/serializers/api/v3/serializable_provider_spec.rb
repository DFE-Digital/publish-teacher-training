require "rails_helper"

describe API::V3::SerializableProvider do
  let(:provider) { create :provider }
  let(:resource) { described_class.new object: provider }

  it "sets type to providers" do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type "providers" }
  it { should have_attribute(:provider_code).with_value(provider.provider_code) }
  it { should have_attribute(:provider_name).with_value(provider.provider_name) }
  it { should have_attribute(:recruitment_cycle_year).with_value(provider.recruitment_cycle.year) }
  it { should have_attribute(:latitude).with_value(provider.latitude) }
  it { should have_attribute(:longitude).with_value(provider.longitude) }
  it { should have_attribute(:can_sponsor_student_visa).with_value(provider.can_sponsor_student_visa) }
  it { should have_attribute(:can_sponsor_skilled_worker_visa).with_value(provider.can_sponsor_skilled_worker_visa) }
end
