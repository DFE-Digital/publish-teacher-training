# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::SkilledWorkerVisa do
  include_context "add_course_wizard"

  let(:current_step) { :skilled_worker_visa }
  let(:can_sponsor_skilled_worker_visa) { nil }
  let(:wizard_step) { wizard.current_step }

  describe "#valid?" do
    it "is valid when can_sponsor_skilled_worker_visa is true" do
      wizard_step.can_sponsor_skilled_worker_visa = true

      expect(wizard_step).to be_valid
    end

    it "is valid when can_sponsor_skilled_worker_visa is false" do
      wizard_step.can_sponsor_skilled_worker_visa = false

      expect(wizard_step).to be_valid
    end

    it "is invalid when can_sponsor_skilled_worker_visa is nil" do
      wizard_step.can_sponsor_skilled_worker_visa = nil

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:can_sponsor_skilled_worker_visa)).to contain_exactly("Select if candidates can get a sponsored Skilled Worker visa")
    end
  end

  describe ".permitted_params" do
    it "returns [:can_sponsor_skilled_worker_visa]" do
      expect(described_class.permitted_params).to eq(%i[can_sponsor_skilled_worker_visa])
    end
  end
end
