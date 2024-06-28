# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class ConsiderPendingALevelController < ALevelRequirementsController
        def step_params
          if params[current_step].blank? && !@course.accept_pending_a_level.nil?
            ActionController::Parameters.new(
              current_step => { pending_a_level: @course.accept_pending_a_level? ? 'yes' : 'no' }
            )
          else
            params
          end
        end
      end
    end
  end
end
