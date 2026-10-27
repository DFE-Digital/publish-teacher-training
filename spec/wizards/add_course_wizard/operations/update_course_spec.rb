# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Operations::UpdateCourse, type: :wizard do
  let(:provider) { create(:provider) }
  let(:deadline) { (provider.recruitment_cycle.application_end_date - 1.day).end_of_day }

  def update(diff)
    described_class.new(course:, diff:).execute
  end

  context "when a fee-paying course becomes salaried" do
    let(:course) { create(:course, :fee_type_based, provider:, can_sponsor_student_visa: true, can_sponsor_skilled_worker_visa: false) }

    it "saves the funding and the skilled worker visa, and stops sponsoring student visas" do
      result = update(funding_type: "salary", can_sponsor_skilled_worker_visa: true, visa_sponsorship_application_deadline_required: false)

      expect(result).to eq(success: true)
      course.reload
      expect(course.funding).to eq("salary")
      expect(course.can_sponsor_skilled_worker_visa).to be(true)
      expect(course.can_sponsor_student_visa).to be(false)
      expect(course.program_type).to eq(Courses::AssignProgramTypeService.new.execute("salary", course.dup).to_s)
    end

    it "clears the fee fields of the draft enrichment" do
      enrichment = create(:course_enrichment, :initial_draft, course:, fee_uk_eu: 9_000, financial_support: "Bursaries")
      course.reload

      update(funding_type: "salary", can_sponsor_skilled_worker_visa: false)

      expect(enrichment.reload).to have_attributes(fee_uk_eu: nil, financial_support: nil)
    end
  end

  context "when a course starts asking for a visa sponsorship deadline" do
    let(:course) { create(:course, :fee_type_based, provider:, can_sponsor_student_visa: false) }

    it "saves the deadline at the end of the day" do
      result = update(
        can_sponsor_student_visa: true,
        visa_sponsorship_application_deadline_required: true,
        visa_sponsorship_application_deadline_at: CourseWizard::Draft::DateParts.parse(deadline),
      )

      expect(result).to eq(success: true)
      expect(course.reload.visa_sponsorship_application_deadline_at).to be_within(1.second).of(deadline.to_date.in_time_zone.end_of_day)
    end
  end

  context "when a sponsoring course stops asking for a deadline" do
    let(:course) { create(:course, :fee_type_based, provider:, can_sponsor_student_visa: true, visa_sponsorship_application_deadline_at: deadline) }

    it "clears the deadline" do
      update(visa_sponsorship_application_deadline_required: false)

      expect(course.reload.visa_sponsorship_application_deadline_at).to be_nil
      expect(course.can_sponsor_student_visa).to be(true)
    end
  end

  context "when a course stops sponsoring visas" do
    let(:course) { create(:course, :fee_type_based, provider:, can_sponsor_student_visa: true, visa_sponsorship_application_deadline_at: deadline) }

    it "clears the deadline" do
      update(can_sponsor_student_visa: false)

      expect(course.reload.visa_sponsorship_application_deadline_at).to be_nil
    end
  end

  context "when the course rejects the change" do
    let(:course) do
      create(:course, :salary_type_based, provider:, can_sponsor_skilled_worker_visa: false,
                                          school_experience_required: true, school_experience_required_content: "Two weeks")
    end

    it "saves nothing and returns the course's errors" do
      result = update(funding_type: "fee", can_sponsor_student_visa: false)

      expect(result).to eq(success: false, errors: ["School experience required can only be required for salaried or apprenticeship courses"])
      expect(course.reload.funding).to eq("salary")
    end
  end
end
