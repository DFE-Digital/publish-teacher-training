require "rails_helper"

describe "Provider Factory" do
  let(:provider) { create(:provider) }

  it "created provider" do
    expect(provider).to be_instance_of(Provider)
    expect(provider).to be_valid
  end
end
