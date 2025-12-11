# frozen_string_literal: true

module Publish
  module Courses
    class SchoolPlacementsController < ApplicationController
      before_action :authorise_with_pundit

      def index
        @course = course
      end

    private

      def course_to_authorise
        @course_to_authorise ||= provider.courses.find_by!(course_code: params[:code])
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
