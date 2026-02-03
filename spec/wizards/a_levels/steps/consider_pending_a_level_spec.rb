# frozen_string_literal: true

require "rails_helper"

RSpec.describe ALevelSteps::ConsiderPendingALevel do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    context "when pending_a_level is present" do
      it "is valid" do
        wizard_step.pending_a_level = "yes"
        expect(wizard_step).to be_valid

        wizard_step.pending_a_level = "no"
        expect(wizard_step).to be_valid
      end
    end

    context "when pending_a_level is not present" do
      it "is not valid" do
        wizard_step.pending_a_level = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.added?(:pending_a_level, :blank)).to be true
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[pending_a_level])
    end
  end

  describe "#accepting_pending_a_level?" do
    it "returns true when pending_a_level is 'yes'" do
      wizard_step.pending_a_level = "yes"
      expect(wizard_step.accepting_pending_a_level?).to be true
    end

    it "returns false when pending_a_level is 'no'" do
      wizard_step.pending_a_level = "no"
      expect(wizard_step.accepting_pending_a_level?).to be false
    end
  end
end
