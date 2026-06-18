# frozen_string_literal: true

class SchoolExperienceWizard
  include DfE::Wizard

  attr_accessor :recruitment_cycle_year, :provider_code, :course_code

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self) do |graph|
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
