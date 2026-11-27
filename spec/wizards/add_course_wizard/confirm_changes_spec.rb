# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CourseWizard confirm changes", type: :wizard do
  include_context "edit_course_wizard"

  # Answers the visa question of a visa edit, then the deadline question.
  def answer_visa_questions
    start_edit_of(:visa)
    edit_request(:visa_sponsorship, { visa_sponsorship: { can_sponsor_student_visa: "true" } }).save_current_step
    edit_request(
      :visa_sponsorship_application_deadline_required,
      { visa_sponsorship_application_deadline_required: { visa_sponsorship_application_deadline_required: "false" } },
    ).tap(&:save_current_step)
  end

  context "with a published course" do
    let(:course) { create(:course, :published, :fee, provider:, can_sponsor_student_visa: false, accrediting_provider: provider) }

    it "asks to confirm before it saves" do
      wizard = answer_visa_questions

      expect(wizard.next_step).to eq(:confirm_changes)
      expect(wizard.commit_result).to be_nil
      expect(course.reload.can_sponsor_student_visa).to be(false)
    end

    it "saves when the changes are confirmed" do
      answer_visa_questions
      wizard = edit_request(:confirm_changes, { confirm_changes: {} })
      wizard.save_current_step

      expect(wizard.commit_result).to eq(status: :committed, errors: [])
      expect(course.reload.can_sponsor_student_visa).to be(true)
    end
  end

  context "with a draft course" do
    let(:course) { create(:course, :fee, provider:, can_sponsor_student_visa: false, accrediting_provider: provider) }

    it "saves with no confirm" do
      wizard = answer_visa_questions

      expect(wizard.commit_result).to eq(status: :committed, errors: [])
      expect(course.reload.can_sponsor_student_visa).to be(true)
    end
  end
end
