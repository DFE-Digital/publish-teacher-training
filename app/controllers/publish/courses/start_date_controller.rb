# frozen_string_literal: true

module Publish
  module Courses
    class StartDateController < ApplicationController
      include CourseBasicDetailConcern

      def back
        authorize(@provider, :edit?)
        redirect_to new_publish_provider_recruitment_cycle_courses_applications_open_path(path_params)
      end

    private

      def current_step
        :start_date
      end

      def error_keys
        [:start_date]
      end

      def section_key
        "Course start date"
      end
    end
  end
end
