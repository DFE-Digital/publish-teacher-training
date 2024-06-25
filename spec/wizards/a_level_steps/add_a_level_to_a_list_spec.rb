# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelSteps::AddALevelToAList do
  subject(:wizard_step) { described_class.new }

  describe 'validations' do
    it 'is valid with a valid answer' do
      wizard_step.add_another_a_level = 'yes'
      expect(wizard_step).to be_valid

      wizard_step.add_another_a_level = 'no'
      expect(wizard_step).to be_valid
    end

    it 'is not valid without an answer' do
      wizard_step.add_another_a_level = nil
      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.added?(:add_another_a_level, :blank)).to be true
    end
  end
end
