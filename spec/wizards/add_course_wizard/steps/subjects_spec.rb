# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::Subjects do
  subject(:wizard_step) { described_class.new(wizard:, step_id: :subjects) }

  let(:state_store) { instance_double(CourseWizard::StateStores::CourseWizardStore, read: stored_state) }
  let(:wizard) { instance_double(CourseWizard, state_store:) }
  let(:stored_state) { {} }

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

  describe "#primary_level?" do
    let(:stored_state) { { "level" => "primary" } }

    it "returns true when the saved level is primary" do
      expect(wizard_step.primary_level?).to be true
    end
  end

  describe "#secondary_level?" do
    let(:stored_state) { { "level" => "secondary" } }

    it "returns true when the saved level is secondary" do
      expect(wizard_step.secondary_level?).to be true
    end
  end
end
