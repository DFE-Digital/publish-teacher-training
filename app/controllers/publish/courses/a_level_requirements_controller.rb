# frozen_string_literal: true

module Publish
  module Courses
    class ALevelRequirementsController < PublishController

      def edit
        authorize(provider)

        @gcse_requirements_form = GcseRequirementsForm.build_from_course(course)
      end

      private

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

    end
  end
end
