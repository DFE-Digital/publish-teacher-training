module Publish
  module Courses
    class SchoolExperienceController < ApplicationController
      def edit
        @course = find_course
      end

      def update
        @course = find_course

        # ✅ CASE: Coming from the DETAILS textarea page
        if params[:school_experience].present? && params[:course].blank?
          redirect_to publish_provider_recruitment_cycle_course_path(
            @provider.provider_code,
            params[:recruitment_cycle_year],
            @course.course_code,
            school_experience: params[:school_experience]
          )
          return
        end

        # ✅ CASE: Coming from the YES / NO radio page
        school_experience_required =
          ActiveModel::Type::Boolean.new.cast(
            params.dig(:course, :school_experience_required)
          )

        if school_experience_required
          school_experience =
            params[:school_experience].presence ||
            request.query_parameters[:school_experience]

          redirect_to school_experience_details_publish_provider_recruitment_cycle_course_path(
            @provider.provider_code,
            params[:recruitment_cycle_year],
            @course.course_code,
            school_experience: school_experience
          )
        else
          redirect_to publish_provider_recruitment_cycle_course_path(
            @provider.provider_code,
            params[:recruitment_cycle_year],
            @course.course_code,
            school_experience_required: false
          )
        end
      end

      def details
        @course = find_course
      end

      private

      def find_course
        Course.find_by!(course_code: params[:code])
      end
    end
  end
end
