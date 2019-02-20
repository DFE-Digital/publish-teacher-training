require 'rails_helper'

describe "Subject 'Further Education' Factory" do
  let(:subject) { create(:futher_education_subject) }

  it "created subject" do
    expect(subject).to be_instance_of(Subject)
    expect(subject).to be_valid
    expect(subject.subject_name).to eq 'Further Education'
    expect(subject.in?(Subject.further_education)).to be true
  end
end
