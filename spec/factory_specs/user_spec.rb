require 'rails_helper'

describe "User Factory" do
  let(:user) { create(:user) }

  it "created user" do
    expect(user).to be_instance_of(User)
    expect(user).to be_valid
  end
end
