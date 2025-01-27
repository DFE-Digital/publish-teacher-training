# frozen_string_literal: true

module Publish
  module Courses
    class AccreditedProviderController < ApplicationController
      include CourseBasicDetailConcern
      before_action :build_provider, only: %i[edit update]

      def show
        @course = build_course&.decorate
        render_not_found if @course.accrediting_provider.blank?
      end

      def new; end

      def edit; end

      def continue
        authorize(@provider, :can_create_course?)

        if course_params[:accredited_provider_code].blank?
          @errors = { accredited_provider_code: ['Select an accredited provider'] }
          render :new
        else
          super
        end
      end

      def update
        begin
          code = update_course_params[:accredited_provider_code]
        rescue ActionController::ParameterMissing
          @errors = { accredited_provider_code: ['Select an accredited provider'] } if code.blank?
          return render :edit if @errors.present?
        end

        if @course.update(update_params)
          course_updated_message('Accredited provider')
          redirect_to_update_successful
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

      def error_keys
        [:accredited_provider_code]
      end

      def redirect_to_update_successful
        redirect_to(
          details_publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code
          )
        )
      end

      def current_step
        :accredited_provider
      end

      def update_course_params
        params.require(:course).permit(
          :accredited_provider_code,
          :accredited_provider
        )
      end

      def update_params
        {
          accredited_provider_code: update_course_params[:accredited_provider_code]
        }
      end

      def build_course
        super
        authorize @course
      end
    end
  end
end
