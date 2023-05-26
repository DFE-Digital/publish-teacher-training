# frozen_string_literal: true

module Publish
  module Courses
    class ApplicationStatusController < PublishController
      before_action :authorize_provider

      def new
        course
      end

      def update
        course.update(application_status: 'open')
        redirect_to publish_provider_recruitment_cycle_course_path
        flash[:success] = t('course.application_status.opened')
      end

      private

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by(course_code: params[:code]))
      end

      def authorize_provider
        authorize(provider)
      end
    end
  end
end
