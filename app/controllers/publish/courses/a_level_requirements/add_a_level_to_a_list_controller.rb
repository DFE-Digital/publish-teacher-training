# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class AddALevelToAListController < ALevelRequirementsController
        def step_params
          return params if @course.a_level_subject_requirements.blank?

          params[current_step] ||= ActionController::Parameters.new
          params[current_step][:subjects] ||= @course.a_level_subject_requirements

          params
        end
      end
    end
  end
end
