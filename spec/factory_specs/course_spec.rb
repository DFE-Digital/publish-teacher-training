require 'rails_helper'

describe "Course factory" do
  subject { create(:course) }

  it { should be_instance_of(Course) }
  it { should be_valid }

  context "course resulting_in_pgde" do
    subject { create(:course, :resulting_in_pgde) }
    its(:qualification) { should eq("pgde") }
  end
end
