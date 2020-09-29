require "rails_helper"

describe API::V2::SerializableContact do
  let(:contact) { build(:contact) }
  let(:resource) { described_class.new(object: contact) }

  it "sets type to contacts" do
    expect(resource.jsonapi_type).to eq(:contacts)
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { is_expected.to have_type("contacts") }

  it { is_expected.to have_attribute(:name).with_value(contact.name) }
  it { is_expected.to have_attribute(:email).with_value(contact.email) }
  it { is_expected.to have_attribute(:telephone).with_value(contact.telephone) }
  it { is_expected.to have_attribute(:type).with_value(contact.type) }
end
