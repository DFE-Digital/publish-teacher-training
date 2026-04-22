# frozen_string_literal: true

class CourseWizard
  include DfE::Wizard

  attr_accessor :recruitment_cycle_year, :provider_code, :state_key

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
      graph.root :level

      graph.add_node :level, Steps::Level
      graph.add_edge from: :level, to: :courses_index
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::ConfigurableRoutes.new(
      wizard: self,
      namespace: "publish-provider-recruitment-cycle-course-wizard",
    ) do |config|
      config.default_path_arguments = {
        recruitment_cycle_year: config.wizard.recruitment_cycle_year,
        provider_code: config.wizard.provider_code,
        state_key: config.wizard.state_key,
      }

      config.map_step :courses_index, to: lambda { |_wizard, options, helpers|
        options = options.except(:state_key)
        helpers.publish_provider_recruitment_cycle_courses_path(**options)
      }
    end
  end
end
