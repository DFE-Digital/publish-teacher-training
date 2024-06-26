# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelSteps::ConsiderPendingALevel do
  subject(:wizard_step) { described_class.new(wizard:) }

  let(:provider) { create(:provider) }
  let(:course) { create(:course, :with_teacher_degree_apprenticeship, provider:) }
  let(:wizard) do
    ALevelsWizard.new(
      current_step: :consider_pending_a_level,
      provider:,
      course:,
      step_params: ActionController::Parameters.new(
        consider_pending_a_level: ActionController::Parameters.new(step_params)
      )
    )
  end
  let(:step_params) { { pending_a_level: } }
  let(:pending_a_level) { 'yes' }

  describe '#valid?' do
    context 'when pending_a_level is present' do
      it 'is valid' do
        wizard_step.pending_a_level = 'yes'
        expect(wizard_step).to be_valid

        wizard_step.pending_a_level = 'no'
        expect(wizard_step).to be_valid
      end
    end

    context 'when pending_a_level is not present' do
      let(:pending_a_level) { nil }

      it 'is not valid' do
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.added?(:pending_a_level, :blank)).to be true
      end
    end
  end

  describe '.permitted_params' do
    it 'returns the correct permitted params' do
      expect(described_class.permitted_params).to eq(%i[pending_a_level])
    end
  end

  describe '#next_step' do
    it 'returns the correct next step' do
      expect(wizard_step.next_step).to eq(:a_level_equivalencies)
    end
  end
end
