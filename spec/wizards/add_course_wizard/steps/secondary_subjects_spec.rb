# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::SecondarySubjects do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    context "when master_subject_id is present" do
      it "is valid" do
        wizard_step.master_subject_id = "1"
        expect(wizard_step).to be_valid
      end
    end

    context "when master_subject_id is not present" do
      it "is not valid without a master_subject_id" do
        wizard_step.master_subject_id = nil
        expect(wizard_step).not_to be_valid
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[master_subject_id subordinate_subject_id])
    end
  end
end
