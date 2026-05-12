# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Public::V1::SerializableSubject do
  subject { JSON.parse(resource.as_jsonapi.to_json) }

  let(:non_bursary_subject) { find_or_create(:primary_subject, :primary_with_english) }
  let(:resource) { described_class.new(object: non_bursary_subject) }

  it "sets type to users" do
    expect(resource.jsonapi_type).to eq(:subjects)
  end

  it { is_expected.to have_type "subjects" }
  it { is_expected.to have_attribute(:name).with_value(non_bursary_subject.subject_name) }
  it { is_expected.to have_attribute(:code).with_value(non_bursary_subject.subject_code) }
  it { is_expected.to have_attribute(:subject_knowledge_enhancement_course_available).with_value(nil) }

  context "when a non-bursary subject" do
    it { is_expected.to have_attribute(:bursary_amount).with_value(nil) }
    it { is_expected.to have_attribute(:early_career_payments).with_value(nil) }
    it { is_expected.to have_attribute(:scholarship).with_value(nil) }
    it { is_expected.to have_attribute(:subject_knowledge_enhancement_course_available).with_value(nil) }
  end

  context "when a hidden future financial incentive exists" do
    let(:bursary_subject) { find_or_create(:secondary_subject, :physics) }
    let(:resource) { described_class.new(object: bursary_subject) }

    before do
      create(:financial_incentive, :hidden, subject: bursary_subject, year: 2027, bursary_amount: "99999")
    end

    it { is_expected.to have_attribute(:bursary_amount).with_value("24000") }
    it { is_expected.to have_attribute(:scholarship).with_value("26000") }
  end

  context "when every financial incentive for the subject is hidden" do
    let(:bursary_subject) { find_or_create(:secondary_subject, :physics) }
    let(:resource) { described_class.new(object: bursary_subject.reload) }

    before do
      bursary_subject.financial_incentive_records.find_each do |financial_incentive|
        financial_incentive.update!(displayed: false)
      end

      create(
        :financial_incentive,
        :hidden,
        subject: bursary_subject,
        year: 2027,
        bursary_amount: "99999",
        early_career_payments: "88888",
        scholarship: "77777",
      )
    end

    it { is_expected.to have_attribute(:bursary_amount).with_value(nil) }
    it { is_expected.to have_attribute(:early_career_payments).with_value(nil) }
    it { is_expected.to have_attribute(:scholarship).with_value(nil) }
  end
end
