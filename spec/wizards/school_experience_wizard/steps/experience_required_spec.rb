# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolExperienceWizard::Steps::ExperienceRequired do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    # School experience is optional, so the step does not validate the answer.
    # An empty submit is allowed and simply returns the user to the course.
    it "is valid whether or not an answer is given" do
      wizard_step.experience_required = true
      expect(wizard_step).to be_valid

      wizard_step.experience_required = false
      expect(wizard_step).to be_valid

      wizard_step.experience_required = nil
      expect(wizard_step).to be_valid
    end
  end

  describe "boolean casting" do
    it "casts the submitted radio string values to booleans" do
      wizard_step.experience_required = "true"
      expect(wizard_step.experience_required).to be(true)

      wizard_step.experience_required = "false"
      expect(wizard_step.experience_required).to be(false)
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[experience_required])
    end
  end
end
