# frozen_string_literal: true

module Publish
  module Courses
    class DesignTechnologyController < ApplicationController
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
      before_action :build_course_params, only: [:continue]
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        return if has_design_technology_subject?

        redirect_to next_step
      end

      def design_technology_subject_id
        @design_technology_subject_id ||= @course.edit_course_options[:design_technology_subjects].id
      end

      def has_design_technology_subject?
        @course.course_subjects.any? { |subject| subject.subject.id == design_technology_subject_id }
      end

      def current_step
        :design_technology
      end

      def build_course_params
        build_new_course
      end

      def error_keys
        [:design_technology_subjects]
      end
    end
  end
end
