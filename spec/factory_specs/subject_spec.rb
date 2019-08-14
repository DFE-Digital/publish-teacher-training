require 'rails_helper'

describe "Subject Factory" do
  describe "Subject 'Further Education' Factory" do
    let(:subject) { create(:further_education_subject) }

    it { should be_instance_of(Subject) }
    it { should be_valid }
    its(:subject_name) { should eq 'Further Education' }
    it { should be_in(Subject.further_education) }
  end
end
