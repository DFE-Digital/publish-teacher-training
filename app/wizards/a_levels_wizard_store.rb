# frozen_string_literal: true

class ALevelsWizardStore < DfE::Wizard::Store
  delegate :valid_step?, to: :wizard

  def save
    return false unless valid_step?

    WhatALevelIsRequiredStore.new(wizard).save if current_step_name == :what_a_level_is_required
    ConsiderPendingALevelStore.new(wizard).save if current_step_name == :consider_pending_a_level
    ALevelEquivalenciesStore.new(wizard).save if current_step_name == :a_level_equivalencies

    true
  end

  def destroy
    RemoveALevelSubjectConfirmationStore.new(wizard).destroy if current_step_name == :remove_a_level_subject_confirmation
  end
end
