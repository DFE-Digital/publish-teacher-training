# frozen_string_literal: true

require "rails_helper"

RSpec.describe ALevelsWizard::Steps::AddALevelToAList do
  subject(:wizard_step) { described_class.new }

  let(:state_store) { instance_double(ALevelsWizard::StateStores::ALevel, subjects:) }
  let(:wizard) { instance_double(ALevelsWizard, state_store:) }
  let(:subjects) { [] }

  before do
    allow(wizard_step).to receive(:wizard).and_return(wizard) # rubocop:disable RSpec/SubjectStub
  end

  describe "validations" do
    it "is valid with a valid answer" do
      wizard_step.add_another_a_level = "yes"
      expect(wizard_step).to be_valid

      wizard_step.add_another_a_level = "no"
      expect(wizard_step).to be_valid
    end

    context "when maximum A level subjects reached" do
      let(:subjects) { [1, 2, 3, 4] }

      it "is valid without an answer" do
        wizard_step.add_another_a_level = nil
        expect(wizard_step).to be_valid
      end
    end

    it "is not valid without an answer" do
      wizard_step.add_another_a_level = nil
      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.added?(:add_another_a_level, :blank)).to be true
    end
  end

  describe "#maximum_number_of_a_level_subjects?" do
    context "when fewer than 4 subjects" do
      let(:subjects) { [1, 2, 3] }

      it "returns false" do
        expect(wizard_step.maximum_number_of_a_level_subjects?).to be false
      end
    end

    context "when exactly 4 subjects" do
      let(:subjects) { [1, 2, 3, 4] }

      it "returns true" do
        expect(wizard_step.maximum_number_of_a_level_subjects?).to be true
      end
    end

    context "when more than 4 subjects" do
      let(:subjects) { [1, 2, 3, 4, 5] }

      it "returns true" do
        expect(wizard_step.maximum_number_of_a_level_subjects?).to be true
      end
    end
  end
end
