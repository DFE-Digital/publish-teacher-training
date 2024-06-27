# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class ALevelEquivalenciesController < ALevelRequirementsController
        def step_params
          if params[current_step].blank? && !@course.accept_a_level_equivalency.nil?
            ActionController::Parameters.new(
              current_step => {
                accept_a_level_equivalency: @course.accept_a_level_equivalency? ? 'yes' : 'no',
                additional_a_level_equivalencies: @course.additional_a_level_equivalencies
              }
            )
          else
            params
          end
        end
      end
    end
  end
end
