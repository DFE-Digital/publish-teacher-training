# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CourseWizard edit journey", type: :wizard do
  include_context "edit_course_wizard"

  let(:deadline) { (provider.recruitment_cycle.application_end_date - 1.day).end_of_day }
  let(:course) do
    create(:course, :fee, provider:, accrediting_provider: provider, can_sponsor_student_visa: true,
                          can_sponsor_skilled_worker_visa: false, visa_sponsorship_application_deadline_at: deadline)
  end

  describe "#opening_step" do
    it "opens a funding type edit on the funding type question" do
      expect(start_edit_of(:funding_type)).to eq(:funding_type)
    end

    it "opens a visa edit on the first visa question on the path" do
      expect(start_edit_of(:visa)).to eq(:visa_sponsorship)
    end

    it "opens a visa edit on its first question when the question it names is not on the path" do
      course.update!(can_sponsor_student_visa: false, visa_sponsorship_application_deadline_at: nil)

      expect(start_edit_of(:visa_sponsorship_application_deadline_at)).to eq(:visa_sponsorship)
    end

    it "opens a visa edit on the visa question it names" do
      expect(start_edit_of(:visa_sponsorship_application_deadline_at)).to eq(:visa_sponsorship_application_deadline_at)
      expect(edit_request.unit).to eq(:visa)
    end

    it "seeds answers that every question on the path accepts" do
      start_edit_of(:funding_type)
      wizard = edit_request

      expect(wizard.question_steps).to eq(
        %i[funding_type visa_sponsorship visa_sponsorship_application_deadline_required visa_sponsorship_application_deadline_at],
      )
      expect(wizard.question_steps).to all(satisfy { |step| wizard.valid?(step) })
      expect(changes?(wizard)).to be(false)
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

  describe ".unit_for" do
    it "is the visa edit only for a visa link, so any other link gets the funding type check" do
      expect(CourseWizard.unit_for("visa")).to eq(:visa)
      expect(CourseWizard.unit_for("visa_sponsorship_application_deadline_at")).to eq(:visa)
      expect(CourseWizard.unit_for("funding_type")).to eq(:funding_type)
      expect(CourseWizard.unit_for(nil)).to eq(:funding_type)
      expect(CourseWizard.unit_for("level")).to eq(:funding_type)
    end
  end

  describe "#question_steps" do
    it "is empty when a change to the course's answers leaves the edit no question to ask" do
      start_edit_of(:funding_type)
      edit_request.state_store.write(qualification: "undergraduate_degree_with_qts")

      expect(edit_request.question_steps).to be_empty
    end
  end

  describe "navigation" do
    it "asks the visa questions a funding change brings, then goes to the course page" do
      start_edit_of(:funding_type)

      expect(answer(:funding_type, funding_type: "salary").next_step).to eq(:skilled_worker_visa)
      expect(answer(:skilled_worker_visa, can_sponsor_skilled_worker_visa: "true").next_step)
        .to eq(:visa_sponsorship_application_deadline_required)
      expect(answer(:visa_sponsorship_application_deadline_required, visa_sponsorship_application_deadline_required: "false").next_step)
        .to eq(:course_page)
    end

    it "goes straight to the course page when the funding is unchanged" do
      start_edit_of(:funding_type)

      expect(answer(:funding_type, funding_type: "fee").next_step).to eq(:course_page)
    end

    it "retraces the questions it asked, then goes back to the course page" do
      start_edit_of(:funding_type)
      answer(:funding_type, funding_type: "salary")
      answer(:skilled_worker_visa, can_sponsor_skilled_worker_visa: "true")

      expect(edit_request(:visa_sponsorship_application_deadline_required).previous_step).to eq(:skilled_worker_visa)
      expect(edit_request(:skilled_worker_visa).previous_step).to eq(:funding_type)
      expect(edit_request(:funding_type).previous_step).to eq(:course_page)
    end

    it "does not open questions outside the edit, or before the one it opened on" do
      start_edit_of(:visa_sponsorship_application_deadline_required)
      wizard = edit_request

      expect(wizard.accessible?(:visa_sponsorship_application_deadline_at)).to be(true)
      expect(wizard.accessible?(:visa_sponsorship)).to be(false)
      expect(wizard.accessible?(:level)).to be(false)
      expect(wizard.accessible?(:check_answers)).to be(false)
    end

    it "opens nothing when the URL names an opening step outside the edit" do
      start_edit_of(:visa_sponsorship_application_deadline_required)
      wizard = edit_request(:visa_sponsorship_application_deadline_required, { return_to_review: "level" })

      expect(wizard.accessible?(:visa_sponsorship_application_deadline_required)).to be(false)
      expect(wizard.question_steps.first).to eq(:visa_sponsorship)
    end

    context "with a published course" do
      let(:course) { create(:course, :published, :fee, provider:, accrediting_provider: provider, can_sponsor_student_visa: false) }

      it "asks to confirm a change before it is saved" do
        start_edit_of(:visa)
        answer(:visa_sponsorship, can_sponsor_student_visa: "true")
        wizard = answer(:visa_sponsorship_application_deadline_required, visa_sponsorship_application_deadline_required: "false")

        expect(wizard.next_step).to eq(:confirm_changes)
        expect(wizard.accessible?(:confirm_changes)).to be(true)
        expect(edit_request(:confirm_changes).next_step).to eq(:course_page)
        expect(edit_request(:confirm_changes).previous_step).to eq(:visa_sponsorship_application_deadline_required)
      end

      context "when it sponsors visas with a deadline" do
        let(:course) do
          create(:course, :published, :fee, provider:, accrediting_provider: provider, can_sponsor_student_visa: true,
                                            visa_sponsorship_application_deadline_at: deadline)
        end

        it "goes back from the confirm page to the last question still on the path" do
          start_edit_of(:visa)
          answer(:visa_sponsorship_application_deadline_required, visa_sponsorship_application_deadline_required: "true")
          answer(:visa_sponsorship_application_deadline_at, deadline_params(deadline - 1.day))
          answer(:visa_sponsorship_application_deadline_required, visa_sponsorship_application_deadline_required: "false")

          expect(edit_request(:confirm_changes).previous_step).to eq(:visa_sponsorship_application_deadline_required)
        end

        it "does not ask to confirm the same deadline written with leading zeros" do
          start_edit_of(:visa_sponsorship_application_deadline_at)
          wizard = answer(:visa_sponsorship_application_deadline_at, deadline_params(deadline, padded: true))

          expect(changes?(wizard)).to be(false)
          expect(wizard.next_step).to eq(:course_page)
        end
      end

      it "does not open the confirm page while a question needs an answer" do
        start_edit_of(:visa)
        answer(:visa_sponsorship, can_sponsor_student_visa: "true")

        expect(edit_request.accessible?(:confirm_changes)).to be(false)
      end

      it "does not ask to confirm when nothing changed" do
        start_edit_of(:visa)

        expect(answer(:visa_sponsorship, can_sponsor_student_visa: "false").next_step).to eq(:course_page)
      end
    end
  end

  def deadline_params(date, padded: false)
    pattern = padded ? "%02d" : "%d"
    {
      "visa_sponsorship_application_deadline_at(3i)" => sprintf(pattern, date.day),
      "visa_sponsorship_application_deadline_at(2i)" => sprintf(pattern, date.month),
      "visa_sponsorship_application_deadline_at(1i)" => date.year.to_s,
    }
  end

  describe "changes" do
    it "is true when the answers on the path change the course" do
      start_edit_of(:funding_type)
      answer(:funding_type, funding_type: "salary")
      answer(:skilled_worker_visa, can_sponsor_skilled_worker_visa: "true")

      expect(changes?(edit_request)).to be(true)
    end
  end
end
