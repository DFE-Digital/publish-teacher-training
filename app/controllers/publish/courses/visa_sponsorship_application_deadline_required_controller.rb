# frozen_string_literal: true

module Publish
  module Courses
    class VisaSponsorshipApplicationDeadlineRequiredController < ApplicationController
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        @deadline_required_form = VisaSponsorshipApplicationDeadlineRequiredForm.new(date_required_params)
      end

      def edit
        authorize(provider)
        @deadline_required_form = VisaSponsorshipApplicationDeadlineRequiredForm.new(
          {
            course:,
            visa_sponsorship_application_deadline_required: course.visa_sponsorship_application_deadline_at.present?,
            origin: origin_param || "visa_sponsorship_deadline_required",
          },
        )
        set_back_link
      end

      def update
        authorize(provider)
        @deadline_required_form = VisaSponsorshipApplicationDeadlineRequiredForm.new(
          date_required_params.merge(course:, origin: origin_param || "visa_sponsorship_deadline_required"),
        )
        if @deadline_required_form.valid?
          @deadline_required_form.update!
          redirect_action_after_update
        else
          set_back_link
          render :edit
        end
      end

    private

      def set_back_link
        @back_link_path = if @deadline_required_form.origin == "visa_sponsorship_deadline_required"
                            details_publish_provider_recruitment_cycle_course_path(
                              *course_nav_params, origin: @deadline_required_form.origin
                            )
                          elsif course.visa_type == "student"
                            student_visa_sponsorship_publish_provider_recruitment_cycle_course_path(
                              *course_nav_params, origin: @deadline_required_form.origin
                            )
                          else
                            skilled_worker_visa_sponsorship_publish_provider_recruitment_cycle_course_path(
                              *course_nav_params, origin: @deadline_required_form.origin
                            )
                          end
      end

      def course_nav_params
        [course.provider_code, course.recruitment_cycle_year, course.course_code]
      end

      def redirect_action_after_update
        if @deadline_required_form.visa_sponsorship_application_deadline_required
          redirect_to(
            visa_sponsorship_application_deadline_date_publish_provider_recruitment_cycle_course_path(
              *course_nav_params,
              origin: @deadline_required_form.origin,
            ),
          )
        else
          flash[:success] = I18n.t(
            "publish.courses.visa_sponsorship_application_deadline_required.update.success.#{@deadline_required_form.origin}",
          )
          redirect_to(details_publish_provider_recruitment_cycle_course_path(*course_nav_params))
        end
      end

      def current_step
        :visa_sponsorship_application_deadline_required
      end

      def date_required_params
        course_params.permit(:visa_sponsorship_application_deadline_required)
      end

      def origin_param
        params[:origin] || params.dig("course", "origin")
      end

      def errors
        @deadline_required_form = VisaSponsorshipApplicationDeadlineRequiredForm.new(date_required_params)
        @deadline_required_form.validate
        @deadline_required_form.errors.messages
      end
    end
  end
end
