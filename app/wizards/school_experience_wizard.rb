# frozen_string_literal: true

class SchoolExperienceWizard
  include DfE::Wizard

  attr_accessor :recruitment_cycle_year, :provider_code, :course_code

  delegate :experience_is_required?, to: :state_store

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
      graph.root(:experience_required)

      graph.add_conditional_edge(
        from: :experience_required,
        when: :experience_is_required?,
        then: :experience_details,
        else: :course_edit,
        label: "Experience is required?",
      )
      graph.add_edge from: :experience_details, to: :course_edit

      graph.add_node :experience_required, Steps::ExperienceRequired
      graph.add_node :experience_details, Steps::ExperienceDetails
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::ConfigurableRoutes.new(
      wizard: self,
      namespace: "publish-provider-recruitment-cycle-course-school-experience",
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
