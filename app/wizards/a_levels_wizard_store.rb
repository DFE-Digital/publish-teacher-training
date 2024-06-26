# frozen_string_literal: true

class ALevelsWizardStore < DfE::Wizard::Store
  delegate :valid_step?, to: :wizard

  def save
    return false unless valid_step?

    AreAnyALevelsRequiredStore.new(wizard).save if current_step_name == :are_any_a_levels_required_for_this_course
    WhatALevelIsRequiredStore.new(wizard).save if current_step_name == :what_a_level_is_required
    ConsiderPendingALevelStore.new(wizard).save if current_step_name == :consider_pending_a_level
    ALevelEquivalenciesStore.new(wizard).save if current_step_name == :a_level_equivalencies

    true
  end
end
