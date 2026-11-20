# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Mapper, type: :wizard do
  include_context "edit_course_wizard"

  let(:deadline) { (provider.recruitment_cycle.application_end_date - 1.day).end_of_day }

  describe "#to_answers" do
    context "with a fee-paying course that sponsors student visas, with a deadline" do
      let(:course) do
        create(:course, :fee, provider:, can_sponsor_student_visa: true, can_sponsor_skilled_worker_visa: false,
                              visa_sponsorship_application_deadline_at: deadline)
      end

      it "gives the student visa answers and not the skilled worker visa answer" do
        expect(described_class.new.to_answers(course)).to eq(
          level: "primary",
          qualification: "pgce_with_qts",
          funding_type: "fee",
          can_sponsor_student_visa: true,
          visa_sponsorship_application_deadline_required: true,
          visa_sponsorship_application_deadline_at: CourseWizard::Draft::DateParts.parse(deadline),
        )
      end
    end

    context "with a salaried course that does not sponsor visas" do
      let(:course) { create(:course, :salary, provider:, can_sponsor_skilled_worker_visa: false) }

      it "gives the skilled worker visa answer and no deadline answers" do
        expect(described_class.new.to_answers(course)).to eq(
          level: "primary",
          qualification: "pgce_with_qts",
          funding_type: "salary",
          can_sponsor_skilled_worker_visa: false,
        )
      end
    end

    context "with a further education course" do
      let(:course) { create(:course, :fee, provider:, level: :further_education, qualification: :pgce, can_sponsor_student_visa: false) }

      it "gives no visa answers" do
        expect(described_class.new.to_answers(course).keys).to eq(%i[level qualification funding_type])
      end
    end
  end
end
