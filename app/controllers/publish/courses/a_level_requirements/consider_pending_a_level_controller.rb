# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class ConsiderPendingALevelController < ALevelRequirementsController
        def step_params
          params
        end
      end
    end
  end
end
