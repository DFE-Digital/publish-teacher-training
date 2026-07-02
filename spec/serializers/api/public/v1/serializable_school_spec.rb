# frozen_string_literal: true

require "rails_helper"

describe API::Public::V1::SerializableSchool do
  subject { JSON.parse(resource.as_jsonapi.to_json) }

  let(:location) { create(:provider_school) }
  let(:resource) { described_class.new(object: location) }

  it "sets type to locations" do
    expect(resource.jsonapi_type).to eq(:locations)
  end

  it { is_expected.to have_type "locations" }

  it { is_expected.to have_attribute(:name).with_value(location.gias_school.name) }
  it { is_expected.to have_attribute(:urn).with_value(location.gias_school.urn) }
  it { is_expected.to have_attribute(:city).with_value(location.gias_school.town) }
  it { is_expected.to have_attribute(:code).with_value(location.site_code) }
  it { is_expected.to have_attribute(:county).with_value(location.gias_school.county) }
  it { is_expected.to have_attribute(:latitude).with_value(location.gias_school.latitude) }
  it { is_expected.to have_attribute(:longitude).with_value(location.gias_school.longitude) }
  it { is_expected.to have_attribute(:postcode).with_value(location.gias_school.postcode) }
  it { is_expected.to have_attribute(:street_address_1).with_value(location.gias_school.address1) }
  it { is_expected.to have_attribute(:street_address_2).with_value(location.gias_school.address2) }
  it { is_expected.to have_attribute(:street_address_3).with_value(location.gias_school.address3) }
  # it { is_expected.to have_attribute(:region_code).with_value(location.gias_school.region_code) }
  # it { is_expected.to have_attribute(:uuid).with_value(location.gias_school.uuid) }

  context "relationships" do
    context "default" do
      it { is_expected.to have_relationships(:provider, :recruitment_cycle) }
    end

    context "with a course" do
      let(:resource) { described_class.new(object: location, course: build_stubbed(:course)) }

      it { is_expected.to have_relationships(:course, :provider, :recruitment_cycle) }
    end
  end
end
