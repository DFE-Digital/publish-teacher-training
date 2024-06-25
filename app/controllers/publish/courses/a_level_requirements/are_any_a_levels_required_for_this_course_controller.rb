# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class AreAnyALevelsRequiredForThisCourseController < ALevelRequirementsController
        private

        def step_params
          if @course_decorator.a_levels_requirements_answered? && params[current_step].blank?
            ActionController::Parameters.new(
              current_step => { answer: @course.a_level_requirements? ? 'yes' : 'no' }
            )
          else
            params
          end
        end
      end
    end
  end
end
