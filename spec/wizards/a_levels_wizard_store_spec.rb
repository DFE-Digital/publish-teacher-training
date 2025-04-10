# frozen_string_literal: true

require "rails_helper"

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
        { current_step => ActionController::Parameters.new(step_params) },
      ),
    )
  end
  let(:step_params) { {} }

  describe "#save" do
    subject { store.save }

    context "when the step is not valid" do
      before do
        allow(wizard).to receive(:valid_step?).and_return(false)
      end

      it "returns false" do
        expect(store.save).to be false
      end
    end

    context "when current step name is :what_a_level_is_required" do
      let(:current_step) { :what_a_level_is_required }
      let(:step_params) { {} }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it "calls save on WhatALevelIsRequiredStore" do
        what_a_level_store = instance_double(WhatALevelIsRequiredStore)
        allow(WhatALevelIsRequiredStore).to receive(:new).with(wizard).and_return(what_a_level_store)
        allow(what_a_level_store).to receive(:save)

        subject

        expect(what_a_level_store).to have_received(:save)
      end
    end

    context "when current step name is :consider_pending_a_level" do
      let(:current_step) { :consider_pending_a_level }
      let(:step_params) { {} }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it "calls save on WhatALevelIsRequiredStore" do
        consider_pending_a_level_store = instance_double(ConsiderPendingALevelStore)
        allow(ConsiderPendingALevelStore).to receive(:new).with(wizard).and_return(consider_pending_a_level_store)
        allow(consider_pending_a_level_store).to receive(:save)

        subject

        expect(consider_pending_a_level_store).to have_received(:save)
      end
    end

    context "when current step name is :a_level_equivalencies" do
      let(:current_step) { :a_level_equivalencies }
      let(:step_params) { {} }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it "calls save on ALevelEquivalenciesStore" do
        a_level_equivalencies_store = instance_double(ALevelEquivalenciesStore)
        allow(ALevelEquivalenciesStore).to receive(:new).with(wizard).and_return(a_level_equivalencies_store)
        allow(a_level_equivalencies_store).to receive(:save)

        subject

        expect(a_level_equivalencies_store).to have_received(:save)
      end
    end

    context "when current step is not recognized" do
      let(:current_step) { :some_other_step }
      let(:step_params) { {} }

      before do
        allow(wizard).to receive(:valid_step?).and_return(true)
      end

      it "does not call any store save method" do
        expect(WhatALevelIsRequiredStore).not_to receive(:new)
        expect(ConsiderPendingALevelStore).not_to receive(:new)
        expect(ALevelEquivalenciesStore).not_to receive(:new)

        subject
      end
    end
  end

  describe "#destroy" do
    context "when current step name is :remove_a_level_subject_confirmation" do
      let(:current_step) { :remove_a_level_subject_confirmation }

      it "calls destroy on RemoveALevelSubjectConfirmationStore" do
        remove_store = instance_double(RemoveALevelSubjectConfirmationStore)
        allow(RemoveALevelSubjectConfirmationStore).to receive(:new).with(wizard).and_return(remove_store)
        allow(remove_store).to receive(:destroy)

        store.destroy

        expect(remove_store).to have_received(:destroy)
      end
    end

    context "when current step name is not :remove_a_level_subject_confirmation" do
      let(:current_step) { :some_other_step }

      it "does not call destroy on RemoveALevelSubjectConfirmationStore" do
        expect(RemoveALevelSubjectConfirmationStore).not_to receive(:new)
        store.destroy
      end
    end
  end
end
