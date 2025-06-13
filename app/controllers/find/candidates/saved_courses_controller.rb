module Find
  module Candidates
    class SavedCoursesController < ApplicationController
      before_action :require_authentication

      def index
        @candidate = Current.user
      end

      def create
        SavedCourse.find_or_create_by!(
          candidate_id: params[:candidate_id],
          course_id: params[:course_id],
        )

        @course = Course.find(params[:course_id])
        @candidate = Current.user

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_back fallback_location: root_path }
        end
      end

      def destroy
        saved_course = SavedCourse.find(params[:id])
        @course = Course.find(saved_course.course_id)
        @candidate = Current.user
        saved_course.destroy

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_back fallback_location: root_path }
        end
      end
    end
  end
end
