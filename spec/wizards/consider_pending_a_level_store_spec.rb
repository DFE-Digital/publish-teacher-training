# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConsiderPendingALevelStore do
  subject(:store) { described_class.new(wizard) }

  let(:course) { create(:course) }
  let(:provider) { build(:provider) }
  let(:current_step) { :consider_pending_a_level }

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

  describe '#save' do
    context 'when accepting pending A levels' do
      let(:step_params) { { pending_a_level: 'yes' } }

      it 'saves as true' do
        expect { store.save }.to change { wizard.course.reload.accept_pending_a_level }.to(true)
      end
    end

    context 'when not accepting pending A levels' do
      let(:step_params) { { pending_a_level: 'no' } }

      it 'saves as false' do
        expect { store.save }.to change { wizard.course.reload.accept_pending_a_level }.to(false)
      end
    end
  end
end
