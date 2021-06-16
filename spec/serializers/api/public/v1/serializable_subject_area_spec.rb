require "rails_helper"

describe API::Public::V1::SerializableSubjectArea do
  let(:subject_area) { find_or_create(:subject_area, :primary) }
  let(:resource) { described_class.new(object: subject_area) }

  it "sets type to subject_areas" do
    expect(resource.jsonapi_type).to eq(:subject_areas)
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { is_expected.to have_type "subject_areas" }

  it { is_expected.to have_attribute(:name).with_value(subject_area.name) }
  it { is_expected.to have_attribute(:typename).with_value(subject_area.typename) }

  context "relationships" do
    context "default" do
      it { is_expected.to have_relationships(:subjects) }
    end
  end
end
