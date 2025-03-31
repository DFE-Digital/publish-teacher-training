# frozen_string_literal: true

module Publish
  module Courses
    class VisaSponsorshipApplicationDeadlineDateController < ApplicationController
      include CourseBasicDetailConcern
      def new
        authorize(@provider, :can_create_course?)
        @deadline_form = VisaSponsorshipApplicationDeadlineDateForm.build_from_form(
          deadline_params,
          recruitment_cycle: @provider.recruitment_cycle,
        )
      end

      def edit
        authorize(provider)
        @deadline_form = VisaSponsorshipApplicationDeadlineDateForm.new(
          {
            course:,
            visa_sponsorship_application_deadline_at: course.visa_sponsorship_application_deadline_at,
            origin: origin_param || "visa_sponsorship_deadline_date",
          },
        )
        set_back_link
      end

      def update
        authorize(provider)
        @deadline_form = VisaSponsorshipApplicationDeadlineDateForm.build_from_form(
          deadline_params,
          origin: origin_param || "visa_sponsorship_deadline_date",
          course:,
        )

        if @deadline_form.valid?
          @deadline_form.update!
          flash[:success] = I18n.t("publish.courses.visa_sponsorship_application_deadline_date.update.success.#{@deadline_form.origin}")
          redirect_to(details_publish_provider_recruitment_cycle_course_path(*course_nav_params))
        else
          set_back_link
          render :edit
        end
      end

    private

      def set_back_link
        @back_link_path = if @deadline_form.origin == "visa_sponsorship_deadline_date"
                            details_publish_provider_recruitment_cycle_course_path(
                              *course_nav_params, origin: @deadline_form.origin
                            )
                          else
                            visa_sponsorship_application_deadline_required_publish_provider_recruitment_cycle_course_path(
                              *course_nav_params, origin: @deadline_form.origin
                            )
                          end
      end

      def course_nav_params
        [course.provider_code, course.recruitment_cycle_year, course.course_code]
      end

      def current_step
        :visa_sponsorship_application_deadline_at
      end

      def errors
        @deadline_form = VisaSponsorshipApplicationDeadlineDateForm.build_from_form(
          deadline_params,
          recruitment_cycle: @provider.recruitment_cycle,
        )
        @deadline_form.validate
        @deadline_form.errors.messages
      end

      def deadline_params
        course_params.permit(:visa_sponsorship_application_deadline_at)
      end

      def origin_param
        params[:origin] || params.dig("course", "origin")
      end
    end
  end
end
