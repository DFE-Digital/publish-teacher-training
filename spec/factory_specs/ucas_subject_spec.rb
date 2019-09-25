require "rails_helper"

describe "UCASSubject Factory" do
  describe "Subject 'Further Education' Factory" do
    let(:subject) { create(:further_education_subject) }

    it { should be_instance_of(UCASSubject) }
    it { should be_valid }
    its(:subject_name) { should eq "Further Education" }
    it { should be_in(UCASSubject.further_education) }
  end
end
