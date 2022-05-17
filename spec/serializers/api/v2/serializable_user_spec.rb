require "rails_helper"

describe API::V2::SerializableUser do
  let(:user)     { create :user }
  let(:resource) { API::V2::SerializableUser.new object: user }

  it "sets type to users" do
    expect(resource.jsonapi_type).to eq :users
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { is_expected.to have_type "users" }
  it { is_expected.to have_attribute(:state).with_value(user.state.to_s) }
  it { is_expected.to have_attribute(:sign_in_user_id).with_value(user.sign_in_user_id.to_s) }
  it { is_expected.to have_attribute(:associated_with_accredited_body).with_value(false) }

  context "when a non admin user" do
    it { is_expected.to have_attribute(:admin).with_value(false) }
  end

  context "when an admin user" do
    let(:user)     { create :user, :admin }

    it { is_expected.to have_attribute(:admin).with_value(true) }
  end
end
