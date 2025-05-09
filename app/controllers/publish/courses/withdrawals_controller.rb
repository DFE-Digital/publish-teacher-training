# frozen_string_literal: true

module Publish
  module Courses
    class WithdrawalsController < ApplicationController
      before_action :redirect_to_courses, if: :course_withdrawn?
      before_action :redirect_to_courses, unless: -> { course.is_published? }

      def edit
        @course_withdrawal_form = CourseWithdrawalForm.new(course)
      end

      def update
        @course_withdrawal_form = CourseWithdrawalForm.new(course)

        if @course_withdrawal_form.save!
          flash[:success] = "#{course.name} (#{course.course_code}) has been withdrawn"

          redirect_to publish_provider_recruitment_cycle_courses_path(
            provider.provider_code,
            recruitment_cycle.year,
          )
        else
          render :edit
        end
      end

    private

      def redirect_to_courses
        message = if course_withdrawn?
                    "#{course.name} (#{course.course_code}) has already been withdrawn"
                  else
                    "Courses that have not been published should be deleted not withdrawn"
                  end

        flash[:error] = { id: "withdraw-error", message: }

        redirect_to publish_provider_recruitment_cycle_courses_path(
          provider.provider_code,
          course.recruitment_cycle_year,
        )
      end

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def course_withdrawn?
        course.content_status == :withdrawn
      end
    end
  end
end
