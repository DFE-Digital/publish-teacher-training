# frozen_string_literal: true

module Publish
  module Courses
    class DeletionsController < ApplicationController
      before_action :redirect_to_courses, if: -> { course&.is_published? }

      def edit
        @course_deletion_form = CourseDeletionForm.new(course)
      end

      def destroy
        @course_deletion_form = CourseDeletionForm.new(course, params: deletion_params)

        if @course_deletion_form.destroy!
          flash[:success] = "#{@course.name} (#{@course.course_code}) has been deleted"

          # Should we redirect to the current years courses?
          redirect_to publish_provider_recruitment_cycle_courses_path(
            provider.provider_code,
            recruitment_cycle.year
          )
        else
          render :edit
        end
      end

      private

      def redirect_to_courses
        redirect_to publish_provider_recruitment_cycle_courses_path(
          provider.provider_code,
          course.recruitment_cycle_year
        )
      end

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by(course_code: params[:code]))
      end

      def deletion_params
        params.expect(publish_course_deletion_form: CourseDeletionForm::FIELDS)
      end
    end
  end
end
