# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::FundingAndVisaRules do
  describe "#reset_opposite_visa" do
    it "stops a fee-paying course sponsoring skilled worker visas" do
      course = build(:course, :fee, can_sponsor_student_visa: true, can_sponsor_skilled_worker_visa: true)
      described_class.new(course).reset_opposite_visa

      expect(course).to have_attributes(can_sponsor_student_visa: true, can_sponsor_skilled_worker_visa: false)
    end

    it "stops a salaried course sponsoring student visas" do
      course = build(:course, :salary, can_sponsor_student_visa: true, can_sponsor_skilled_worker_visa: true)
      described_class.new(course).reset_opposite_visa

      expect(course).to have_attributes(can_sponsor_student_visa: false, can_sponsor_skilled_worker_visa: true)
    end
  end

  describe "#clear_deadline_unless_sponsoring" do
    it "clears the deadline of a course that sponsors no visa" do
      course = build(:course, :fee, can_sponsor_student_visa: false, visa_sponsorship_application_deadline_at: 1.month.from_now)
      described_class.new(course).clear_deadline_unless_sponsoring

      expect(course.visa_sponsorship_application_deadline_at).to be_nil
    end

    it "keeps the deadline of a course that sponsors its visa" do
      deadline = 1.month.from_now.change(usec: 0)
      course = build(:course, :fee, can_sponsor_student_visa: true, visa_sponsorship_application_deadline_at: deadline)
      described_class.new(course).clear_deadline_unless_sponsoring

      expect(course.visa_sponsorship_application_deadline_at).to eq(deadline)
    end
  end

  describe "#reset_enrichment" do
    it "clears the fee fields of a salaried course's draft enrichment, unsaved" do
      course = create(:course, :salary)
      create(:course_enrichment, :initial_draft, course:, fee_uk_eu: 9_000)

      enrichment = described_class.new(course.reload).reset_enrichment

      expect(enrichment.fee_uk_eu).to be_nil
      expect(enrichment).to be_changed
    end

    it "returns nil for a course with no saved enrichment" do
      expect(described_class.new(create(:course, :fee)).reset_enrichment).to be_nil
    end
  end
end
