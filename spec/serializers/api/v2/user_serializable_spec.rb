require 'rails_helper'

describe API::V2::UserSerializable do
  let(:user)     { create :user }
  let(:resource) { API::V2::UserSerializable.new object: user }

  it 'sets type to users' do
    expect(resource.jsonapi_type).to eq :users
  end

  subject { resource.as_jsonapi.to_json }

  it { should be_json.with_content(type: 'users') }
end
