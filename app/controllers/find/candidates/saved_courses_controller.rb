module Find
  module Candidates
    class SavedCoursesController < ApplicationController
      before_action :require_authentication

      def index
        @saved_courses = @candidate.saved_courses
      end

      def create
        course = Course.find(params[:course_id])

        if SaveCourseService.call(candidate: @candidate, course:)
          redirect_to_course(course)
        else
          redirect_to_course(course, error: t(".save_failed"))
        end
      end

      def destroy
        saved_course = @candidate.saved_courses.find(params[:id])
        course = Course.find(saved_course.course_id)

        if saved_course.destroy
          redirect_to_course(course)
        else
          redirect_to_course(course, error: t(".unsave_failed"))
        end
      end

    private

      def redirect_to_course(course, error: nil)
        options = {
          provider_code: course.provider_code,
          course_code: course.course_code,
        }

        flash_options = error ? { flash: { error: { message: error } } } : {}
        redirect_to find_course_path(**options), **flash_options
      end
    end
  end
end
