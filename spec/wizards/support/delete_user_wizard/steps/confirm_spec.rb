# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::DeleteUserWizard::Steps::Confirm do
  subject(:wizard_step) { described_class.new }

  describe "#valid?" do
    it "is valid with no submitted answers" do
      expect(wizard_step).to be_valid
    end
  end

  describe ".permitted_params" do
    it "permits no fields" do
      expect(described_class.permitted_params).to eq([])
    end
  end
end
