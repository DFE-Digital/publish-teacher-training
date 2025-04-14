# frozen_string_literal: true

module Publish
  module Courses
    class VisaSponsorshipApplicationDeadlineDateController < ApplicationController
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        @deadline_form = VisaSponsorshipApplicationDeadlineDateForm.build(
          **date_params_for_form,
          recruitment_cycle: @provider.recruitment_cycle,
        )
      end

      def edit
        authorize(provider)
        @deadline_form = VisaSponsorshipApplicationDeadlineDateForm.new(
          {
            course:,
            recruitment_cycle: course.recruitment_cycle,
            visa_sponsorship_application_deadline_at: course.visa_sponsorship_application_deadline_at,
            starting_step:,
          },
        )
        set_back_link
      end

      def update
        authorize(provider)
        @deadline_form = VisaSponsorshipApplicationDeadlineDateForm.build(
          **date_params_for_form,
          recruitment_cycle: course.recruitment_cycle,
          starting_step:,
          course:,
        )

        if @deadline_form.valid?
          @deadline_form.update!
          flash[:success] = t(".success.#{@deadline_form.starting_step}")
          redirect_to(details_publish_provider_recruitment_cycle_course_path(*course_nav_params))
        else
          set_back_link
          render :edit
        end
      end

    private

      def set_back_link
        @back_link_path = if @deadline_form.started_at_current_step?
                            details_publish_provider_recruitment_cycle_course_path(*course_nav_params)
                          else
                            visa_sponsorship_application_deadline_required_publish_provider_recruitment_cycle_course_path(
                              *course_nav_params, starting_step: @deadline_form.starting_step
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
        # This method is only used in the CourseBasicDetailConcern for the new / create methods.
        @deadline_form = VisaSponsorshipApplicationDeadlineDateForm.build(
          **date_params_for_form,
          recruitment_cycle: @provider.recruitment_cycle,
        )
        @deadline_form.validate
        @deadline_form.errors.messages
      end

      def deadline_params
        course_params.permit(:visa_sponsorship_application_deadline_at)
      end

      def date_params_for_form
        {
          year: deadline_params["visa_sponsorship_application_deadline_at(1i)"],
          month: deadline_params["visa_sponsorship_application_deadline_at(2i)"],
          day: deadline_params["visa_sponsorship_application_deadline_at(3i)"],
        }
      end

      def starting_step
        params[:starting_step] ||
          params.dig("course", "starting_step") ||
          VisaSponsorshipApplicationDeadlineDateForm::CURRENT_STEP
      end
    end
  end
end
