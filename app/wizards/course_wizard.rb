# frozen_string_literal: true

class CourseWizard
  include DfE::Wizard

  attr_accessor :recruitment_cycle_year, :provider_code, :state_key

  delegate :further_education_level?, :primary_level?, :undergraduate_degree_with_qts?, to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
      graph.root :level

      graph.add_node :level, Steps::Level
      graph.add_node :primary_subjects, Steps::PrimarySubjects
      graph.add_node :secondary_subjects, Steps::SecondarySubjects
      graph.add_node :age_range, Steps::AgeRange
      graph.add_node :qualifications, Steps::Qualifications
      graph.add_node :funding_type, Steps::FundingType
      graph.add_node :study_pattern, Steps::StudyPattern

      graph.add_node :courses_index, DfE::Wizard::Core::Redirect

      graph.add_multiple_conditional_edges(
        from: :level,
        branches: [
          { when: :further_education_level?, then: :qualifications },
          { when: :primary_level?, then: :primary_subjects },
        ],
        default: :secondary_subjects,
      )

      graph.add_multiple_conditional_edges(
        from: :qualifications,
        branches: [
          { when: :undergraduate_degree_with_qts?, then: :courses_index },
        ],
        default: :funding_type,
      )

      graph.add_edge from: :primary_subjects, to: :age_range
      graph.add_edge from: :secondary_subjects, to: :age_range

      graph.add_edge from: :age_range, to: :qualifications

      graph.add_edge from: :funding_type, to: :study_pattern

      graph.add_edge from: :study_pattern, to: :courses_index
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::DynamicRoutes.new(
      state_store:,
      path_builder: lambda { |step_id, _state_store, helpers, options|
        case step_id
        when :courses_index
          helpers.publish_provider_recruitment_cycle_courses_path(
            provider_code:,
            recruitment_cycle_year:,
            **options.except(:state_key),
          )
        else
          helpers.publish_provider_recruitment_cycle_course_wizard_path(
            provider_code:,
            recruitment_cycle_year:,
            state_key:,
            step: step_id,
            **options,
          )
        end
      },
    )
  end
end
