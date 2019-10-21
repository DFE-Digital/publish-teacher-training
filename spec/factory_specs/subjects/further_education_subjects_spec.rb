require "rails_helper"

describe "FurtherEducationSubject factory" do
  subject { find_or_create(:further_education_subject) }

  it { should be_instance_of(FurtherEducationSubject) }
  it { should be_valid }
  its(:subject_name) { should eq("Further education") }
  its(:subject_code) { should eq("41") }
end
