require 'rails_helper'

describe "Subject Factory" do
  describe "Subject 'Further Education' Factory" do
    let(:subject) { create(:futher_education_subject) }

    it "created subject" do
      expect(subject).to be_instance_of(Subject)
      expect(subject).to be_valid
      expect(subject.subject_name).to eq 'Further Education'
      expect(subject.in?(Subject.further_education)).to be true
    end
  end

  describe "Subject 'Send' Factory" do
    let(:subject) { create(:send_subject) }

    it { should be_instance_of(Subject) }
    it { should be_valid }
    its(:subject_name) { should eq 'Special Educational Needs' }
    its(:subject_code) { should eq 'U3' }
  end
end
