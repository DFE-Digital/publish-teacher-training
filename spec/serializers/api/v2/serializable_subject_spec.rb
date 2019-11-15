require "rails_helper"

describe API::V2::SerializableSubject do
  let(:non_bursary_subject) { find_or_create :primary_subject }
  let(:resource) { API::V2::SerializableSubject.new object: non_bursary_subject }

  it "sets type to users" do
    expect(resource.jsonapi_type).to eq :subjects
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type "subjects" }
  it { should have_attribute(:subject_name).with_value(non_bursary_subject.subject_name) }
  it { should have_attribute(:subject_code).with_value(non_bursary_subject.subject_code) }


  context "when a non-bursary subject" do
    it { should have_attribute(:bursary_amount).with_value(nil) }
    it { should have_attribute(:early_career_payments).with_value(nil) }
    it { should have_attribute(:scholarship).with_value(nil) }
  end

  context "when a bursary subject" do
    let(:bursary_subject) { find_or_create :secondary_subject, :mathematics }
    let(:resource) { API::V2::SerializableSubject.new object: bursary_subject }

    it { should have_attribute(:bursary_amount).with_value(bursary_subject.financial_incentive.bursary_amount) }
    it { should have_attribute(:early_career_payments).with_value(bursary_subject.financial_incentive.early_career_payments) }
    it { should have_attribute(:scholarship).with_value(bursary_subject.financial_incentive.scholarship) }
  end
end
