module Find
  module Candidates
    class SavedCoursesController < ApplicationController
      before_action :require_authentication
      after_action :send_save_course_analytics_event, only: [:create]

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

      def undo
        course = Course.find(params[:course_id])

        if SaveCourseService.call(candidate: @candidate, course:)
          redirect_to find_candidate_saved_courses_path
        else
          redirect_to find_candidate_saved_courses_path(course, error: t(".save_failed"))
        end
      end

      def destroy
        saved_course = @candidate.saved_courses.find(params[:id])
        course = saved_course.course

        if saved_course.destroy
          undo_link = view_context.render(
            partial: "find/candidates/saved_courses/undo_link",
            locals: { label: t(".undo"), undo_path: undo_find_candidate_saved_courses_path, course: },
          )

          flash[:success_with_body] = {
            title: t(".success_message_title"),
            body: t(
              ".success_message_html",
              provider_name: course.provider_name,
              course_name_and_code: course.name_and_code,
              undo_link: undo_link,
            ),
          }

          redirect_to find_candidate_saved_courses_path
        else
          redirect_to_course(course, error: t(".unsave_failed"))
        end
      end

    private

      def send_save_course_analytics_event
        Analytics::SaveCourseEvent.new(
          request:,
          candidate_id: @candidate.id,
          course_id: @course.id,
        ).send_event
      end

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
