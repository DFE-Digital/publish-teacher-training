require "rails_helper"

describe Subject, type: :model do
  subject { find_or_create(:modern_languages_subject, subject_name: "Modern languages (other)", subject_code: "101") }

  it { should have_many(:courses).through(:course_subjects) }
  its(:to_sym) { should eq(:modern_languages_other) }
  its(:to_s) { should eq("Modern languages (other)") }

  it "can get a financial incentive" do
    financial_incentive = create(:financial_incentive, subject: subject)
    expect(subject.financial_incentive).to eq(financial_incentive)
  end

  it "returns all active subjects" do
    expect(described_class.active.pluck(:type)).not_to include("DiscontinuedSubject")
  end
end
