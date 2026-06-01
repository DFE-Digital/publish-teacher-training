# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::FundingType do
  include_context "add_course_wizard"

  let(:current_step) { :funding_type }
  let(:current_step_params) { { funding_type: } }
  let(:funding_type) { nil }

  describe "#valid?" do
    subject(:wizard_step) { wizard.current_step }

    it "is valid when funding type is present" do
      wizard_step.funding_type = "fee"
      expect(wizard_step).to be_valid
    end

    it "is not valid when funding type is not present" do
      expect(wizard_step).not_to be_valid
    end

    it "is not valid when funding type is not in the list of options" do
      wizard_step.funding_type = "invalid"
      expect(wizard_step).not_to be_valid
    end
  end

  describe "#funding_type_options" do
    subject(:wizard_step) { wizard.current_step }

    it "returns the funding type options" do
      expect(wizard_step.funding_type_options).to eq(%w[fee salary apprenticeship])
    end
  end

  describe "#self.permitted_params" do
    it "returns the permitted params" do
      expect(described_class.permitted_params).to eq([:funding_type])
    end
  end
end
