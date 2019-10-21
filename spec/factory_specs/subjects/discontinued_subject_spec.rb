require "rails_helper"

describe "PrimarySubject factory" do
  subject { find_or_create(:discontinued_subject) }

  it { should be_instance_of(DiscontinuedSubject) }
  it { should be_valid }

  context "humanities" do
    subject { find_or_create(:discontinued_subject, :humanities) }
    its(:subject_name) { should eq("Humanities") }
    its(:subject_code) { should eq(nil) }
  end

  context "balanced_science" do
    subject { find_or_create(:discontinued_subject, :balanced_science) }
    its(:subject_name) { should eq("Balanced Science") }
    its(:subject_code) { should eq(nil) }
  end
end
