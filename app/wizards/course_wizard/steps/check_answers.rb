# frozen_string_literal: true

class CourseWizard
  module Steps
    class CheckAnswers
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      validate :every_question_answered

      def self.permitted_params
        []
      end

    private

      # Each unanswered question gets the error its own step shows, keyed by
      # the step so the error summary links to that row.
      def every_question_answered
        wizard.invalid_steps.each do |step|
          errors.add(step.step_id, step.errors.first.message)
        end
      end
    end
  end
end
