# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolExperienceWizard::Steps::ExperienceRequired do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    context "when experience_required is present" do
      it "is valid" do
        wizard_step.experience_required = "yes"
        expect(wizard_step).to be_valid

        wizard_step.experience_required = "no"
        expect(wizard_step).to be_valid
      end
    end

    context "when experience_required is not present" do
      it "is not valid" do
        wizard_step.experience_required = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.added?(:experience_required, :blank)).to be true
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[experience_required])
    end
  end
end
