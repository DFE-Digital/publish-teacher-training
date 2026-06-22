# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::PhysicsSpecialisms do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    context "when campaign_name is selected as engineers teach physics" do
      it "is valid" do
        wizard_step.campaign_name = "engineers_teach_physics"
        expect(wizard_step).to be_valid
      end
    end

    context "when campaign_name is selected as no campaign" do
      it "is valid" do
        wizard_step.campaign_name = "no_campaign"
        expect(wizard_step).to be_valid
      end
    end

    context "when campaign_name is blank" do
      it "is not valid" do
        wizard_step.campaign_name = nil
        expect(wizard_step).not_to be_valid
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq([:campaign_name])
    end
  end
end
