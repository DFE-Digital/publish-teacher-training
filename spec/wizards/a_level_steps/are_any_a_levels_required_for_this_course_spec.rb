# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelSteps::AreAnyALevelsRequiredForThisCourse do
  subject(:wizard_step) { described_class.new }

  describe 'validations' do
    it 'is valid with a valid answer' do
      wizard_step.answer = 'yes'
      expect(wizard_step).to be_valid

      wizard_step.answer = 'no'
      expect(wizard_step).to be_valid
    end

    it 'is not valid without an answer' do
      wizard_step.answer = nil
      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.added?(:answer, :blank)).to be true
    end
  end

  describe '.permitted_params' do
    it 'returns the permitted params' do
      expect(described_class.permitted_params).to eq([:answer])
    end
  end

  describe '#previous_step' do
    it 'returns the symbol for the previous step' do
      expect(wizard_step.previous_step).to eq(:first_step)
    end
  end

  describe '#next_step' do
    context 'when a level is required' do
      it 'returns the name for the next step' do
        wizard_step.answer = 'yes'
        expect(wizard_step.next_step).to eq(:what_a_level_is_required)
      end
    end

    context 'when a level is not required' do
      it 'returns the name for the next step' do
        wizard_step.answer = 'no'
        expect(wizard_step.next_step).to eq(:exit)
      end
    end
  end
end
