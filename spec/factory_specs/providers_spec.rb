require "rails_helper"

describe "Provider Factory" do
  subject { create(:provider) }

  it { should be_instance_of(Provider) }
  it { should be_valid }

  it "creates the correct number of associations" do
    expect { subject }.to change { Organisation.count }.by(1).
        and change { User.count }.by(1)
  end
end
