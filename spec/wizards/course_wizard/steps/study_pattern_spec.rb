# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::StudyPattern do
  include_context "add_course_wizard"

  let(:current_step) { :study_pattern }
  let(:current_step_params) { { study_pattern: } }
  let(:study_pattern) { nil }

  describe "#valid?" do
    subject(:wizard_step) { wizard.current_step }

    it "is valid when a single study pattern is selected" do
      wizard_step.study_pattern = %w[full_time]
      expect(wizard_step).to be_valid
    end

    it "is valid when multiple study patterns are selected" do
      wizard_step.study_pattern = %w[full_time part_time]
      expect(wizard_step).to be_valid
    end

    it "is not valid when study pattern is not present" do
      expect(wizard_step).not_to be_valid
    end

    it "is not valid when study pattern is not in the list of options" do
      wizard_step.study_pattern = %w[invalid]
      expect(wizard_step).not_to be_valid
    end
  end

  describe "#study_pattern_options" do
    subject(:wizard_step) { wizard.current_step }

    it "returns the study pattern options" do
      expect(wizard_step.study_pattern_options).to eq(%w[full_time part_time])
    end
  end

  describe "#self.permitted_params" do
    it "returns the permitted params" do
      expect(described_class.permitted_params).to eq([{ study_pattern: [] }])
    end
  end
end
