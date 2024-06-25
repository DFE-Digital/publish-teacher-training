# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelsWizardStore do
  subject(:store) { described_class.new(wizard) }

  let(:wizard) do
    ALevelsWizard.new(
      current_step:,
      provider:,
      course:,
      step_params: ActionController::Parameters.new(
        { current_step => ActionController::Parameters.new(step_params) }
      )
    )
  end
  let(:course) { build(:course) }
  let(:provider) { build(:provider) }
  let(:step_params) { {} }
  let(:current_step) { :are_any_a_levels_required_for_this_course }

  describe '#save' do
    context 'when the step is not valid' do
      before do
        allow(wizard).to receive(:valid_step?).and_return(false)
      end

      it 'returns false' do
        expect(store.save).to be false
      end
    end

    context 'when the step is valid and current step is :are_any_a_levels_required_for_this_course with answer "no"' do
      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
        allow(wizard.current_step).to receive(:answer).and_return('no')
      end

      it 'updates the course a_level_requirements to false' do
        expect(course).to receive(:update!).with(a_level_requirements: false)
        store.save
      end

      it 'returns true' do
        allow(course).to receive(:update!).with(a_level_requirements: false)
        expect(store.save).to be true
      end
    end

    context 'when the step is valid and the current step is :are_any_a_levels_required_for_this_course with an answer other than "no"' do
      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
        allow(wizard.current_step).to receive(:answer).and_return('yes')
      end

      it 'does not update the course a_level_requirements' do
        expect(course).not_to receive(:update!)
        store.save
      end

      it 'returns true' do
        expect(store.save).to be true
      end
    end

    context 'when the step is valid and the current step is not :are_any_a_levels_required_for_this_course' do
      let(:current_step) { :some_other_step }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it 'does not update the course a_level_requirements' do
        expect(course).not_to receive(:update!)
        store.save
      end

      it 'returns true' do
        expect(store.save).to be true
      end
    end
  end
end
