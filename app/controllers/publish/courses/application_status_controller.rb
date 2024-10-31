# frozen_string_literal: true

module Publish
  module Courses
    class ApplicationStatusController < ApplicationController
      def new
        course
      end

      def update
        new_status = course.application_status_closed? ? 'open' : 'closed'

        course.update(application_status: new_status)
        flash[:success] = t("course.application_status.#{new_status}")
        redirect_to publish_provider_recruitment_cycle_course_path
      end

      private

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by(course_code: params[:code]))
      end
    end
  end
end
