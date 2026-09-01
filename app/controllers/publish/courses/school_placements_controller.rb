# frozen_string_literal: true

module Publish
  module Courses
    class SchoolPlacementsController < ApplicationController
      before_action :authorise_with_pundit

      def index
        @course = course
      end

    private

      # The shared placements partial walks a course's schools, so preload them:
      # this controller had no includes at all and issued a query per school.
      def course_to_authorise
        @course_to_authorise ||= provider.courses.includes(**school_preloads).find_by!(course_code: params[:code])
      end

      def school_preloads
        if FeatureFlag.active?(:course_publishing_uses_new_school_model)
          { schools: %i[gias_school provider_school] }
        else
          { site_statuses: [:site] }
        end
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
