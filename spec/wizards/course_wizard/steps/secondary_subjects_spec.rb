# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::SecondarySubjects do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    context "when secondary_master_subject_id is present" do
      it "is valid" do
        wizard_step.secondary_master_subject_id = "1"
        expect(wizard_step).to be_valid
      end
    end

    context "when secondary_master_subject_id is not present" do
      it "is not valid without a secondary_master_subject_id" do
        wizard_step.secondary_master_subject_id = nil
        expect(wizard_step).not_to be_valid
      end
    end

    context "when secondary_master_subject_id is the same as the subordinate_subject_id" do
      it "is not valid" do
        wizard_step.secondary_master_subject_id = "1"
        wizard_step.subordinate_subject_id = "1"
        expect(wizard_step).not_to be_valid
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[secondary_master_subject_id subordinate_subject_id])
    end
  end
end
