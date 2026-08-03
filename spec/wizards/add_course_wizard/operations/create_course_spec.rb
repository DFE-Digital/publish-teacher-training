# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Operations::CreateCourse, type: :wizard do
  include_context "add_course_wizard"

  let(:current_step) { :check_answers }
  let(:step) { wizard.current_step }
  let(:operation) { described_class.new(repository: state_store, step:) }
  let(:serialized_params) { ActionController::Parameters.new(level: "primary").permit! }

  # The operation re-runs valid?(:new) before saving, which clears the course's
  # errors, so the courses here have to be genuinely valid or genuinely invalid -
  # errors stubbed onto them would not survive to be reported.
  before do
    allow(Courses::WizardParamsSerializer).to receive(:call).with(wizard:).and_return(serialized_params)
    allow(Courses::CreationService).to receive(:call).with(
      course_params: serialized_params,
      provider: wizard.provider,
      next_available_course_code: true,
    ).and_return(course)
  end

  describe "#execute" do
    context "when the created course is valid" do
      let(:course) { build(:course, provider:, sites: [provider.sites.first]) }

      it "saves the course and returns success" do
        expect { expect(operation.execute).to eq(success: true) }
          .to change(Course, :count).by(1)
      end
    end

    context "when the created course has no school" do
      let(:course) { build(:course, provider:, sites: []) }

      it "reports the course's own validation errors and saves nothing" do
        result = nil

        expect { result = operation.execute }.not_to change(Course, :count)

        expect(result[:success]).to be(false)
        expect(result[:errors]).to eq(step.errors)
        expect(step.errors[:base]).to include("Select at least one school")
      end
    end
  end

  describe "wizard integration" do
    let(:course) { build(:course, provider:, sites: []) }

    it "causes save_current_step to return false when the created course is invalid" do
      expect(wizard.save_current_step).to be(false)
      expect(wizard.current_step.errors[:base]).to include("Select at least one school")
    end
  end
end
