module Publish
  module Courses
    class SchoolExperienceController < ApplicationController
      def edit
        @course = find_course
      end

     def update
  @course = find_course

  school_experience_required =
    ActiveModel::Type::Boolean.new.cast(
      params.dig(:course, :school_experience_required)
    )

  if school_experience_required
    # YES → school experience details page
    redirect_to school_experience_details_publish_provider_recruitment_cycle_course_path(
      @provider.provider_code,
      params[:recruitment_cycle_year],
      @course.course_code
    )
  else
    # NO → course SHOW page
    redirect_to publish_provider_recruitment_cycle_course_path(
      @provider.provider_code,
      params[:recruitment_cycle_year],
      @course.course_code
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
