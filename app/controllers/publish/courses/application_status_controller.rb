# frozen_string_literal: true

module Publish
  module Courses
    class ApplicationStatusController < PublishController
      before_action :authorize_provider

      def new
        course
      end

      def update
        new_status = course.application_status_closed? ? 'open' : 'closed'

        course.update(application_status: new_status)
        flash[:success] = t("course.application_status.#{new_status}")
        #         if course.application_status_closed?
        #           course.update(application_status: 'open')
        #           flash[:success] = t('course.application_status.opened')
        #         else
        #           course.update(application_status: 'closed')
        #           flash[:success] = t('course.application_status.closed')
        #         end
        redirect_to publish_provider_recruitment_cycle_course_path
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
