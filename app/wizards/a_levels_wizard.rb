# frozen_string_literal: true

class ALevelsWizard
  include DfE::Wizard

  attr_accessor :recruitment_cycle_year, :provider_code, :course_code

  delegate :another_a_level_needed?, to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
      graph.conditional_root(potential_root: %i[add_a_level_to_a_list what_a_level_is_required]) do |state_store|
        if state_store.any_a_levels?
          :add_a_level_to_a_list
        else
          :what_a_level_is_required
        end
      end

      graph.add_node :what_a_level_is_required, ALevelSteps::WhatALevelIsRequired
      graph.add_node :add_a_level_to_a_list, ALevelSteps::AddALevelToAList
      graph.add_node :remove_a_level_subject_confirmation, ALevelSteps::RemoveALevelSubjectConfirmation
      graph.add_node :consider_pending_a_level, ALevelSteps::ConsiderPendingALevel
      graph.add_node :a_level_equivalencies, ALevelSteps::ALevelEquivalencies

      graph.add_edge from: :what_a_level_is_required, to: :add_a_level_to_a_list

      graph.add_edge from: :remove_a_level_subject_confirmation, to: :add_a_level_to_a_list
      graph.add_edge from: :consider_pending_a_level, to: :a_level_equivalencies
      graph.add_edge from: :a_level_equivalencies, to: :course_edit

      graph.add_conditional_edge(
        from: :add_a_level_to_a_list,
        when: :another_a_level_needed?,
        then: :what_a_level_is_required,
        else: :consider_pending_a_level,
      )
    end
  end
end
