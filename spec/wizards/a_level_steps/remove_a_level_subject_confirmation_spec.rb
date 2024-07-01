# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelSteps::RemoveALevelSubjectConfirmation do
  subject(:wizard_step) { described_class.new(wizard:) }

  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:wizard) do
    ALevelsWizard.new(
      current_step: :remove_a_level_subject_confirmation,
      provider:,
      course:,
      step_params: ActionController::Parameters.new(
        remove_a_level_subject_confirmation: ActionController::Parameters.new({ uuid:, confirmation: })
      )
    )
  end
  let(:uuid) { SecureRandom.uuid }
  let(:confirmation) { 'yes' }

  before { wizard_step.confirmation = confirmation }

  describe 'validations' do
    context 'when confirmation is present' do
      it 'is valid' do
        wizard_step.uuid = uuid
        wizard_step.confirmation = 'yes'
        expect(wizard_step).to be_valid

        wizard_step.confirmation = 'no'
        expect(wizard_step).to be_valid
      end
    end

    context 'when any subject and confirmation is not present' do
      it 'is not valid' do
        wizard_step.subject = 'any_subject'
        wizard_step.confirmation = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:confirmation]).to include('Select if you want to remove Any subject')
      end
    end

    context 'when other subject and confirmation is not present' do
      it 'is not valid' do
        wizard_step.subject = 'other_subject'
        wizard_step.other_subject = 'Mathematics'
        wizard_step.confirmation = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors[:confirmation]).to include('Select if you want to remove Mathematics')
      end
    end

    context 'when uuid is not present' do
      it 'is not valid' do
        wizard_step.uuid = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.added?(:uuid, :blank)).to be true
      end
    end
  end

  describe '.permitted_params' do
    it 'returns permitted params' do
      expect(described_class.permitted_params).to eq(%i[uuid subject other_subject confirmation])
    end
  end

  describe '#next_step' do
    context 'when confirming and no a_level_subject_requirements anymore' do
      let(:confirmation) { 'yes' }
      let(:course) { create(:course, a_level_subject_requirements: [], provider:) }

      it 'returns :exit' do
        expect(wizard_step.next_step).to eq(:exit)
      end
    end

    context 'when confirming and a_level_subject_requirements are present' do
      let(:confirmation) { 'yes' }
      let(:course) { create(:course, :with_a_level_requirements, provider:) }

      it 'returns :add_a_level_to_a_list' do
        expect(wizard_step.next_step).to eq(:add_a_level_to_a_list)
      end
    end

    context 'when answering no to confirm' do
      let(:confirmation) { 'no' }

      it 'returns :add_a_level_to_a_list' do
        expect(wizard_step.next_step).to eq(:add_a_level_to_a_list)
      end
    end
  end
end
