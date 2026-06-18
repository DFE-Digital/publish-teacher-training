# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolExperienceWizard::Steps::ExperienceDetails do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    context "when experience_details is present and within the word limit" do
      it "is valid" do
        wizard_step.experience_details = "Applicants should have spent time in a school."
        expect(wizard_step).to be_valid
      end
    end

    context "when experience_details is not present" do
      it "is not valid" do
        wizard_step.experience_details = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.added?(:experience_details, :blank)).to be true
      end
    end

    context "when experience_details exceeds 250 words" do
      it "is not valid" do
        wizard_step.experience_details = (%w[word] * 251).join(" ")
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:experience_details]).to be_present
      end
    end

    context "when experience_details is exactly 250 words" do
      it "is valid" do
        wizard_step.experience_details = (%w[word] * 250).join(" ")
        expect(wizard_step).to be_valid
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[experience_details])
    end
  end
end
