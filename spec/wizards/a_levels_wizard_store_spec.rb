# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelsWizardStore do
  subject(:store) { described_class.new(wizard) }

  let(:course) { create(:course) }
  let(:provider) { build(:provider) }
  let(:current_step) { :what_a_level_is_required }

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
  let(:step_params) { {} }

  describe '#save' do
    subject { store.save }

    context 'when the step is not valid' do
      before do
        allow(wizard).to receive(:valid_step?).and_return(false)
      end

      it 'returns false' do
        expect(store.save).to be false
      end
    end

    context 'when current step name is :are_any_a_levels_required_for_this_course' do
      let(:current_step) { :are_any_a_levels_required_for_this_course }
      let(:step_params) { {} }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it 'calls save on AreAnyALevelsRequiredStore' do
        are_any_store = instance_double(AreAnyALevelsRequiredStore)
        allow(AreAnyALevelsRequiredStore).to receive(:new).with(wizard).and_return(are_any_store)
        allow(are_any_store).to receive(:save)

        subject

        expect(are_any_store).to have_received(:save)
      end
    end

    context 'when current step name is :what_a_level_is_required' do
      let(:current_step) { :what_a_level_is_required }
      let(:step_params) { {} }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it 'calls save on WhatALevelIsRequiredStore' do
        what_a_level_store = instance_double(WhatALevelIsRequiredStore)
        allow(WhatALevelIsRequiredStore).to receive(:new).with(wizard).and_return(what_a_level_store)
        allow(what_a_level_store).to receive(:save)

        subject

        expect(what_a_level_store).to have_received(:save)
      end
    end

    context 'when current step name is :consider_pending_a_level' do
      let(:current_step) { :consider_pending_a_level }
      let(:step_params) { {} }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it 'calls save on WhatALevelIsRequiredStore' do
        consider_pending_a_level_store = instance_double(ConsiderPendingALevelStore)
        allow(ConsiderPendingALevelStore).to receive(:new).with(wizard).and_return(consider_pending_a_level_store)
        allow(consider_pending_a_level_store).to receive(:save)

        subject

        expect(consider_pending_a_level_store).to have_received(:save)
      end
    end

    context 'when current step is not recognized' do
      let(:current_step) { :some_other_step }
      let(:step_params) { {} }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it 'does not call any store save method' do
        expect(AreAnyALevelsRequiredStore).not_to receive(:new)
        expect(WhatALevelIsRequiredStore).not_to receive(:new)
        expect(ConsiderPendingALevelStore).not_to receive(:new)

        subject
      end
    end
  end
end
