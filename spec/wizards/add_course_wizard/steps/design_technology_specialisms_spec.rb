# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::DesignTechnologySpecialisms do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    context "when at least one specialism is selected" do
      it "is valid" do
        wizard_step.design_technology_ids = %w[1]
        expect(wizard_step).to be_valid
      end
    end

    context "when no specialism is selected" do
      it "is not valid" do
        wizard_step.design_technology_ids = []
        expect(wizard_step).not_to be_valid
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq([{ design_technology_ids: [] }])
    end
  end
end
