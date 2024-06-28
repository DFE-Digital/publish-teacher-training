# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelSteps::ALevelEquivalencies do
  subject(:wizard_step) { described_class.new(wizard:) }

  let(:provider) { create(:provider) }
  let(:course) { create(:course, :with_teacher_degree_apprenticeship, provider:) }
  let(:wizard) do
    ALevelsWizard.new(
      current_step: :a_level_equivalencies,
      provider:,
      course:,
      step_params: ActionController::Parameters.new(
        consider_pending_a_level: ActionController::Parameters.new(step_params)
      )
    )
  end
  let(:step_params) { {} }

  describe '#valid?' do
    context 'when pending_a_level is present' do
      it 'is valid' do
        wizard_step.accept_a_level_equivalency = 'yes'
        expect(wizard_step).to be_valid

        wizard_step.accept_a_level_equivalency = 'no'
        expect(wizard_step).to be_valid
      end
    end

    context 'when pending_a_level is not present' do
      it 'is not valid' do
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.added?(:accept_a_level_equivalency, :blank)).to be true
      end
    end

    context 'when additional_a_level_equivalencies is too long' do
      let(:excess_words) { 5 }
      let(:word_limit) { 250 }
      let(:long_text) { 'word ' * (word_limit + excess_words) }

      it 'is not valid and adds a custom error message' do
        wizard_step.accept_a_level_equivalency = 'yes'
        wizard_step.additional_a_level_equivalencies = long_text
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:additional_a_level_equivalencies]).to include(
          "Details about equivalency tests must be #{word_limit} words or less. You have #{excess_words} words too many"
        )
      end
    end

    context 'when additional_a_level_equivalencies is too long by one word' do
      let(:excess_words) { 1 }
      let(:word_limit) { 250 }
      let(:long_text) { 'word ' * (word_limit + excess_words) }

      it 'is not valid and adds a custom error message' do
        wizard_step.accept_a_level_equivalency = 'yes'
        wizard_step.additional_a_level_equivalencies = long_text
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:additional_a_level_equivalencies]).to include(
          "Details about equivalency tests must be #{word_limit} words or less. You have #{excess_words} word too many"
        )
      end
    end

    context 'when additional_a_level_equivalencies is too long and no equivalencies' do
      let(:excess_words) { 5 }
      let(:word_limit) { 250 }
      let(:long_text) { 'word ' * (word_limit + excess_words) }

      it 'does not validate max words' do
        wizard_step.accept_a_level_equivalency = 'no'
        wizard_step.additional_a_level_equivalencies = 'word ' * 500
        expect(wizard_step).to be_valid
      end
    end
  end

  describe '.permitted_params' do
    it 'returns the correct permitted params' do
      expect(described_class.permitted_params).to eq(%i[accept_a_level_equivalency additional_a_level_equivalencies])
    end
  end

  describe '#next_step' do
    it 'returns the correct next step' do
      expect(wizard_step.next_step).to eq(:exit)
    end
  end
end
