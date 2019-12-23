# == Schema Information
#
# Table name: subject
#
#  created_at   :datetime
#  id           :bigint           not null, primary key
#  subject_code :text
#  subject_name :text
#  type         :text
#  updated_at   :datetime
#
# Indexes
#
#  index_subject_on_subject_name  (subject_name)
#

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
end
