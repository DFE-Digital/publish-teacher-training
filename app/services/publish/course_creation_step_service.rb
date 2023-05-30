# frozen_string_literal: true

module Publish
  class CourseCreationStepService
    def execute(current_step:, course:)
      workflow_steps = WorkflowStepService.call(course)
      {
        next: get_next_step(workflow_steps, current_step),
        previous: get_previous_step(workflow_steps, current_step)
      }
    end

    private

    def get_next_step(steps, current_step)
      next_step_index = steps.find_index(current_step).next
      steps[next_step_index]
    end

    def get_previous_step(steps, current_step)
      previous_step_index = steps.find_index(current_step).pred
      steps[previous_step_index]
    end
  end
end
