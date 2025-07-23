module Find
  module Candidates
    class SavedCoursesController < ApplicationController
      before_action :require_authentication
      after_action :send_saved_course_analytics_event, only: [:create]

      def index
        @saved_courses = @candidate.saved_courses
      end

      def create
        saved_course = SaveCourseService.call(candidate: @candidate, course:)

        respond_to do |format|
          if saved_course
            format.html { redirect_to_course(@course) }
            format.json { render json: { saved_course: saved_course.id }, status: :created }
          else
            format.html { redirect_to_course(@course, error: t(".save_failed")) }
            format.json { render json: { error: t(".save_failed") }, status: :unprocessable_entity }
          end
        end
      end

      def undo
        if SaveCourseService.call(candidate: @candidate, course:)
          redirect_to find_candidate_saved_courses_path
        else
          redirect_to find_candidate_saved_courses_path(course, error: t(".save_failed"))
        end
      end

      def destroy
        saved_course = @candidate.saved_courses.find(params[:id])
        course = saved_course.course

        respond_to do |format|
          if saved_course.destroy
            format.json { render json: { deleted: true }, status: :ok }

            format.html do
              if params[:unsaved_course_on_show_page]
                redirect_to_course(course)
              else
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
              end
            end
          else
            format.json { render json: { error: t(".unsave_failed") }, status: :unprocessable_entity }

            format.html { redirect_to_course(course, error: t(".unsave_failed")) }
          end
        end
      end

    private

      def course
        @course ||= Course.find(params[:course_id])
      end

      def send_saved_course_analytics_event
        Analytics::SavedCourseEvent.new(
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
