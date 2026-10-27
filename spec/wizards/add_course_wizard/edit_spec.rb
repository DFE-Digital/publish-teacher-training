# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Edit, type: :wizard do
  include_context "edit_course_wizard"

  let(:deadline) { (provider.recruitment_cycle.application_end_date - 1.day).end_of_day }
  let(:course) do
    create(:course, :fee, provider:, accrediting_provider: provider, can_sponsor_student_visa: true,
                          can_sponsor_skilled_worker_visa: false, visa_sponsorship_application_deadline_at: deadline)
  end

  describe "#start" do
    it "opens a funding type edit on the funding type question" do
      expect(start_edit_of(:funding_type)).to eq(:funding_type)
    end

    it "opens a visa edit on the first visa question on the path" do
      expect(start_edit_of(:visa)).to eq(:visa_sponsorship)
    end

    it "opens a visa edit on the visa question it names" do
      expect(start_edit_of(:visa_sponsorship_application_deadline_at)).to eq(:visa_sponsorship_application_deadline_at)
      expect(edit_request.edit.unit).to eq(:visa)
    end

    it "seeds answers that every question on the path accepts" do
      start_edit_of(:funding_type)
      wizard = edit_request

      expect(wizard.edit.question_steps).to eq(
        %i[funding_type visa_sponsorship visa_sponsorship_application_deadline_required visa_sponsorship_application_deadline_at],
      )
      expect(wizard.edit.question_steps).to all(satisfy { |step| wizard.valid?(step) })
      expect(wizard.edit.diff).to eq({})
    end

    context "with a TDA course" do
      let(:course) { create(:course, :fee, provider:, qualification: :undergraduate_degree_with_qts) }

      it "does not start a funding type edit, which a TDA course does not ask" do
        expect(start_edit_of(:funding_type)).to be_nil
        expect(repository.read).to be_empty
      end
    end

    context "with a further education course" do
      let(:course) { create(:course, :fee, provider:, level: :further_education, qualification: :pgce) }

      it "does not start a visa edit, which a further education course does not ask" do
        expect(start_edit_of(:visa)).to be_nil
      end
    end
  end

  describe "#active?" do
    it "is true for the course the edit started for" do
      start_edit_of(:funding_type)

      expect(edit_request.edit).to be_active
    end

    it "is false when no edit was started, or the edit has ended" do
      expect(edit_request.edit).not_to be_active
    end

    it "is false for another course" do
      start_edit_of(:funding_type)
      other_course = create(:course, :fee, provider:)

      expect(edit_request.tap { |wizard| wizard.record = other_course }.edit).not_to be_active
    end
  end

  describe "navigation" do
    it "asks the visa questions a funding change brings, then goes to the course page" do
      start_edit_of(:funding_type)

      expect(answer(:funding_type, funding_type: "salary").next_step).to eq(:skilled_worker_visa)
      expect(answer(:skilled_worker_visa, can_sponsor_skilled_worker_visa: "true").next_step)
        .to eq(:visa_sponsorship_application_deadline_required)
      expect(answer(:visa_sponsorship_application_deadline_required, visa_sponsorship_application_deadline_required: "false").next_step)
        .to eq(:courses_index)
    end

    it "goes straight to the course page when the funding is unchanged" do
      start_edit_of(:funding_type)

      expect(answer(:funding_type, funding_type: "fee").next_step).to eq(:courses_index)
    end

    it "retraces the questions it asked, then goes back to the course page" do
      start_edit_of(:funding_type)
      answer(:funding_type, funding_type: "salary")
      answer(:skilled_worker_visa, can_sponsor_skilled_worker_visa: "true")

      expect(edit_request(:visa_sponsorship_application_deadline_required).previous_step).to eq(:skilled_worker_visa)
      expect(edit_request(:skilled_worker_visa).previous_step).to eq(:funding_type)
      expect(edit_request(:funding_type).previous_step).to eq(:courses_index)
    end

    it "does not open questions outside the edit, or before the one it opened on" do
      start_edit_of(:visa_sponsorship_application_deadline_required)
      edit = edit_request.edit

      expect(edit.accessible?(:visa_sponsorship_application_deadline_at)).to be(true)
      expect(edit.accessible?(:visa_sponsorship)).to be(false)
      expect(edit.accessible?(:level)).to be(false)
      expect(edit.accessible?(:check_answers)).to be(false)
    end

    context "with a published course" do
      let(:course) { create(:course, :published, :fee, provider:, accrediting_provider: provider, can_sponsor_student_visa: false) }

      it "asks to confirm a change before it is saved" do
        start_edit_of(:visa)
        answer(:visa_sponsorship, can_sponsor_student_visa: "true")
        wizard = answer(:visa_sponsorship_application_deadline_required, visa_sponsorship_application_deadline_required: "false")

        expect(wizard.next_step).to eq(:confirm_changes)
        expect(wizard.edit.accessible?(:confirm_changes)).to be(true)
        expect(edit_request(:confirm_changes).next_step).to eq(:courses_index)
        expect(edit_request(:confirm_changes).previous_step).to eq(:visa_sponsorship_application_deadline_required)
      end

      it "does not open the confirm page while a question needs an answer" do
        start_edit_of(:visa)
        answer(:visa_sponsorship, can_sponsor_student_visa: "true")

        expect(edit_request.edit.accessible?(:confirm_changes)).to be(false)
      end

      it "does not ask to confirm when nothing changed" do
        start_edit_of(:visa)

        expect(answer(:visa_sponsorship, can_sponsor_student_visa: "false").next_step).to eq(:courses_index)
      end
    end
  end

  describe "#diff" do
    it "holds the changed answers on the path, and not the answers the change took off it" do
      start_edit_of(:funding_type)
      answer(:funding_type, funding_type: "salary")
      answer(:skilled_worker_visa, can_sponsor_skilled_worker_visa: "true")
      answer(:visa_sponsorship_application_deadline_required, visa_sponsorship_application_deadline_required: "false")

      expect(edit_request.edit.diff).to eq(
        funding_type: "salary",
        can_sponsor_skilled_worker_visa: true,
        visa_sponsorship_application_deadline_required: false,
      )
    end
  end

  describe "#commit!" do
    it "saves the changes and ends the edit" do
      start_edit_of(:funding_type)
      answer(:funding_type, funding_type: "salary")
      answer(:skilled_worker_visa, can_sponsor_skilled_worker_visa: "false")

      expect(edit_request.edit.commit!).to eq(status: :committed, errors: [])
      expect(course.reload).to have_attributes(funding: "salary", can_sponsor_skilled_worker_visa: false, can_sponsor_student_visa: false)
      expect(edit_request.edit).not_to be_active
    end

    it "saves nothing when nothing changed" do
      start_edit_of(:funding_type)
      answer(:funding_type, funding_type: "fee")

      expect { expect(edit_request.edit.commit!).to eq(status: :unchanged, errors: []) }
        .not_to(change { course.reload.updated_at })
    end

    it "saves nothing when the course changed since the edit started" do
      start_edit_of(:funding_type)
      answer(:funding_type, funding_type: "salary")
      answer(:skilled_worker_visa, can_sponsor_skilled_worker_visa: "false")
      course.touch

      expect(edit_request.edit.commit!).to eq(status: :stale, errors: [])
      expect(course.reload.funding).to eq("fee")
    end

    context "when the course rejects the change" do
      let(:course) do
        create(:course, :salary_type_based, provider:, accrediting_provider: provider, can_sponsor_skilled_worker_visa: false,
                                            school_experience_required: true, school_experience_required_content: "Two weeks")
      end

      it "returns the errors and ends the edit" do
        start_edit_of(:funding_type)
        answer(:funding_type, funding_type: "fee")
        answer(:visa_sponsorship, can_sponsor_student_visa: "false")

        expect(edit_request.edit.commit!).to eq(
          status: :failed,
          errors: ["School experience required can only be required for salaried or apprenticeship courses"],
        )
        expect(edit_request.edit).not_to be_active
      end
    end
  end
end
