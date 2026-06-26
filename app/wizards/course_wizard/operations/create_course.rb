# frozen_string_literal: true

class CourseWizard
  module Operations
    class CreateCourse
      def initialize(repository:, step:)
        _repository = repository
        @step = step
        @wizard = step.wizard
      end

      def execute
        params = ::Courses::WizardParamsSerializer.call(wizard: @wizard)
        course = ::Courses::CreationService.call(
          course_params: params,
          provider: @wizard.provider,
          next_available_course_code: true,
        )

        if course.save
          { success: true }
        else
          course.errors.full_messages.each { |message| @step.errors.add(:base, message) }
          { success: false, errors: @step.errors }
        end
      end

      def rollback; end
    end
  end
end
