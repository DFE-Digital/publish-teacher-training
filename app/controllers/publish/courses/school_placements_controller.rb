# frozen_string_literal: true

module Publish
  module Courses
    class SchoolPlacementsController < ApplicationController
      include CourseSchoolPreloads

      before_action :authorise_with_pundit

      def index
        @course = course
      end

    private

      # The shared placements partial walks a course's schools, so preload them:
      # this controller had no includes at all and issued a query per school.
      def course_to_authorise
        @course_to_authorise ||= provider.courses.includes(**placement_school_preloads).find_by!(course_code: params[:code])
      end

      def course
        @course ||= CourseDecorator.new(course_to_authorise)
      end

      def authorise_with_pundit
        authorize course_to_authorise
      end
    end
  end
end
