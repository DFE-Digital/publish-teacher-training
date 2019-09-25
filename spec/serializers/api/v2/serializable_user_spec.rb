require "rails_helper"

describe API::V2::SerializableUser do
  let(:user)     { create :user }
  let(:resource) { API::V2::SerializableUser.new object: user }

  it "sets type to users" do
    expect(resource.jsonapi_type).to eq :users
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type "users" }
  it { should have_attribute(:state).with_value(user.state.to_s) }
end
