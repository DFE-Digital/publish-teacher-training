# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Operations::CreateCourse, type: :wizard do
  include_context "add_course_wizard"

  let(:current_step) { :check_answers }
  let(:step) { wizard.current_step }
  let(:operation) { described_class.new(repository: state_store, step:) }
  let(:serialized_params) { ActionController::Parameters.new(level: "primary").permit! }

  describe "#execute" do
    before do
      allow(Courses::WizardParamsSerializer).to receive(:call).with(wizard:).and_return(serialized_params)
    end

    it "returns success when the course saves" do
      course = build(:course)
      allow(course).to receive(:save).and_return(true)
      allow(Courses::CreationService).to receive(:call).with(
        course_params: serialized_params,
        provider: wizard.provider,
        next_available_course_code: true,
      ).and_return(course)

      expect(operation.execute).to eq(success: true)
    end

    it "adds errors to the step and returns failure when save fails" do
      invalid_course = build(:course)
      invalid_course.errors.add(:base, "Could not create course")
      allow(invalid_course).to receive(:save).and_return(false)
      allow(Courses::CreationService).to receive(:call).with(
        course_params: serialized_params,
        provider: wizard.provider,
        next_available_course_code: true,
      ).and_return(invalid_course)

      result = operation.execute

      expect(result[:success]).to be(false)
      expect(result[:errors]).to eq(step.errors)
      expect(step.errors[:base]).to include("Could not create course")
    end
  end

  describe "wizard integration" do
    it "causes save_current_step to return false when the created course is invalid" do
      invalid_course = build(:course)
      invalid_course.errors.add(:base, "Could not create course")
      allow(invalid_course).to receive(:save).and_return(false)
      allow(Courses::WizardParamsSerializer).to receive(:call).with(wizard:).and_return(serialized_params)
      allow(Courses::CreationService).to receive(:call).and_return(invalid_course)

      expect(wizard.save_current_step).to be(false)
      expect(wizard.current_step.errors[:base]).to include("Could not create course")
    end
  end
end
