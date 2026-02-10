# frozen_string_literal: true

class ALevelsWizard
  include DfE::Wizard

  attr_accessor :recruitment_cycle_year, :provider_code, :course_code

  delegate :any_a_levels?, :another_a_level_needed?, :has_remaining_a_levels?, to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
      graph.conditional_root(potential_root: %i[add_a_level_to_a_list what_a_level_is_required]) do |_state_store|
        if any_a_levels?
          :add_a_level_to_a_list
        else
          :what_a_level_is_required
        end
      end

      graph.add_node :what_a_level_is_required, Steps::WhatALevelIsRequired
      graph.add_node :add_a_level_to_a_list, Steps::AddALevelToAList
      graph.add_node :remove_a_level_subject_confirmation, Steps::RemoveALevelSubjectConfirmation
      graph.add_node :consider_pending_a_level, Steps::ConsiderPendingALevel
      graph.add_node :a_level_equivalencies, Steps::ALevelEquivalencies

      graph.add_edge from: :what_a_level_is_required, to: :add_a_level_to_a_list

      graph.add_conditional_edge(
        from: :remove_a_level_subject_confirmation,
        when: :any_a_levels?,
        then: :add_a_level_to_a_list,
        else: :course_edit,
        label: "Has remaining A-levels?",
      )

      graph.add_edge from: :consider_pending_a_level, to: :a_level_equivalencies
      graph.add_edge from: :a_level_equivalencies, to: :course_edit

      graph.add_conditional_edge(
        from: :add_a_level_to_a_list,
        when: :another_a_level_needed?,
        then: :what_a_level_is_required,
        else: :consider_pending_a_level,
        label: "Another A Level needed?",
      )
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::ConfigurableRoutes.new(
      wizard: self,
      namespace: "publish-provider-recruitment-cycle-course-a-levels-or-equivalency-tests",
    ) do |config|
      config.default_path_arguments = {
        recruitment_cycle_year: config.wizard.recruitment_cycle_year,
        provider_code: config.wizard.provider_code,
        course_code: config.wizard.course_code,
      }

      config.map_step :course_edit, to: lambda { |_wizard, options, helpers|
        options[:code] = options.delete(:course_code)
        helpers.publish_provider_recruitment_cycle_course_path(**options)
      }
    end
  end
end
