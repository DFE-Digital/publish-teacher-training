require "rails_helper"

describe API::V2::SerializableOrganisation do
  let(:organisation) { create :organisation }
  let(:resource) { API::V2::SerializableOrganisation.new object: organisation }

  it "sets type to organisations" do
    expect(resource.jsonapi_type).to eq :organisations
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type "organisations" }
  it { should have_attribute(:name).with_value(organisation.name.to_s) }
end
