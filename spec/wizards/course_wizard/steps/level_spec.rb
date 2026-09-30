# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::Level do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    context "when level and is_send are present" do
      it "is valid" do
        wizard_step.level = "primary"
        wizard_step.is_send = "true"
        expect(wizard_step).to be_valid

        wizard_step.level = "secondary"
        wizard_step.is_send = "true"
        expect(wizard_step).to be_valid

        wizard_step.level = "further_education"
        wizard_step.is_send = "true"
        expect(wizard_step).to be_valid
      end
    end

    context "when level or is_send are not present" do
      it "is not valid without a level" do
        wizard_step.level = nil
        expect(wizard_step).not_to be_valid
      end

      it "is not valid without an is_send value" do
        wizard_step.is_send = nil
        expect(wizard_step).not_to be_valid
      end
    end

    context "when level or is_send are not in the allowed options" do
      it "is not valid with an unsupported level" do
        wizard_step.level = "invalid"
        expect(wizard_step).not_to be_valid
      end

      it "is not valid with an unsupported is_send value" do
        wizard_step.is_send = "invalid"
        expect(wizard_step).not_to be_valid
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[level is_send])
    end
  end
end
