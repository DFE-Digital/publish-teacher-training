# frozen_string_literal: true

class ALevelsWizard
  include DfE::Wizard

  # attr_accessor :provider, :course

  # delegate :course_code, to: :course
  # delegate :provider_code, :recruitment_cycle_year, to: :course
  delegate :another_a_level_needed?, to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
      graph.root :what_a_level_is_required
      graph.add_node :what_a_level_is_required, ALevelSteps::WhatALevelIsRequired
      graph.add_node :add_a_level_to_a_list, ALevelSteps::AddALevelToAList
      graph.add_node :remove_a_level_subject_confirmation, ALevelSteps::RemoveALevelSubjectConfirmation
      graph.add_node :consider_pending_a_level, ALevelSteps::ConsiderPendingALevel
      graph.add_node :a_level_equivalencies, ALevelSteps::ALevelEquivalencies

      graph.add_edge from: :what_a_level_is_required, to: :add_a_level_to_a_list

      graph.add_conditional_edge(
        from: :add_a_level_to_a_list,
        when: :another_a_level_needed?,
        then: :what_a_level_is_required,
        else: :consider_pending_a_level,
      )
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::ConfigurableRoutes.new(
      wizard: self,
      namespace: "publish-provider-recruitment-cycle-course-a-levels-or-equivalency-tests",
    ) do |config|
      config.wizard.instance_variable_get(:@current_step_params).slice("recruitment_cycle_year", "provider_code", "course_code").to_h => { recruitment_cycle_year:, provider_code:, course_code: }

      config.default_path_arguments = {
        recruitment_cycle_year: recruitment_cycle_year,
        provider_code: provider_code,
        course_code: course_code,
      }
    end
  end

  # Default argument passed to all the routing in this wizard
  # All course editing specific is done through the URL
  #
  # /publish/organisations/:provider_code/:recruitment_cycle_year/courses/:course_code
  #
  # def default_path_arguments
  #   { provider_code:, recruitment_cycle_year:, course_code: }
  # end

  # Definitions of Rails routes prefix namespace for A levels with default path arguments
  # above.
  #
  # Of one example is the first step to the second step:
  #
  # publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required
  #
  # publish_provider_recruitment_cycle_course - defined below
  # a_levels - ALevelSteps module
  # what_a_level_is_required - WhatALevelIsRequired step
  #
  def default_path_prefix
    "publish_provider_recruitment_cycle_course"
  end

  def exit_path
    url_helpers.publish_provider_recruitment_cycle_course_path(
      provider_code:,
      recruitment_cycle_year:,
      code: course_code,
    )
  end
end
