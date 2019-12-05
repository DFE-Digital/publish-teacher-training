require "rails_helper"

describe API::V2::SerializableOrganisation do
  let(:organisation) { create :organisation, nctl_organisations: [nctl_organisation] }
  let(:nctl_organisation) { build(:nctl_organisation) }
  let(:resource) { API::V2::SerializableOrganisation.new object: organisation }

  it "sets type to organisations" do
    expect(resource.jsonapi_type).to eq :organisations
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type "organisations" }
  it { should have_attribute(:name).with_value(organisation.name.to_s) }
  it { should have_attribute(:nctl_ids).with_value([nctl_organisation.nctl_id]) }
end
