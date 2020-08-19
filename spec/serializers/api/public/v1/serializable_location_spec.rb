require "rails_helper"

describe API::Public::V1::SerializableLocation do
  let(:location) { create(:site) }
  let(:resource) { described_class.new(object: location) }

  it "sets type to locations" do
    expect(resource.jsonapi_type).to eq(:locations)
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type "locations" }

  it { should have_attribute(:city).with_value(location.address3) }
  it { should have_attribute(:code).with_value(location.code) }
  it { should have_attribute(:county).with_value(location.address4) }
  it { should have_attribute(:latitude).with_value(location.latitude) }
  it { should have_attribute(:longitude).with_value(location.longitude) }
  it { should have_attribute(:name).with_value(location.location_name) }
  it { should have_attribute(:postcode).with_value(location.postcode) }
  it { should have_attribute(:region_code).with_value(location.region_code) }
  it { should have_attribute(:street_address_1).with_value(location.address1) }
  it { should have_attribute(:street_address_2).with_value(location.address2) }

  context "relationships" do
    context "default" do
      it { should have_relationships(:provider, :recruitment_cycle) }
    end

    context "with a course" do
      let(:resource) { described_class.new(object: location, course: build_stubbed(:course)) }

      it { should have_relationships(:course, :provider, :recruitment_cycle) }
    end
  end
end
