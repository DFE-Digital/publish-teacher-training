# frozen_string_literal: true

module Publish
  module Courses
    class RatifyingProviderController < ApplicationController
      include CourseBasicDetailConcern
      before_action :build_provider, only: %i[edit update]
      helper_method :accredited_partners

      delegate :accredited_partners, to: :provider

      def show
        @course = build_course&.decorate
        render_not_found if @course.accrediting_provider.blank?
      end

      def new; end

      def edit; end

      def continue
        authorize(@provider, :can_create_course?)

        if course_params[:accredited_provider_code].blank?
          set_error_messages
          render :new
        else
          super
        end
      end

      def update
        if @course.update(update_params)
          course_updated_message("Accredited provider")

          redirect_to(
            details_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
            ),
          )
        else
          @errors = @course.errors.messages
          render :edit
        end
      end

    private

      def build_provider
        @provider = RecruitmentCycle.find_by(year: params[:recruitment_cycle_year])
                                    .providers
                                    .find_by(provider_code: params[:provider_code])
      end

      def build_course
        super
        authorize @course
      end

      def current_step
        :accredited_provider
      end

      def error_keys
        [:accredited_provider_code]
      end

      def set_error_messages
        @errors = { accredited_provider_code: ["Select an accredited provider"] }
      end

      def update_course_params
        params.expect(course: [:accredited_provider_code])
      end

      def update_params
        {
          accredited_provider_code: update_course_params[:accredited_provider_code],
        }
      end
    end
  end
end
