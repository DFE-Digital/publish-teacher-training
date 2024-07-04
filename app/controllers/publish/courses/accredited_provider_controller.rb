# frozen_string_literal: true

module Publish
  module Courses
    class AccreditedProviderController < PublishController
      include CourseBasicDetailConcern
      before_action :build_course, only: %i[edit update]
      before_action :build_course_params, only: :continue

      def show
        @course = build_course&.decorate
        render_not_found if @course.accrediting_provider.blank?
      end

      def edit
        build_provider
      end

      def continue
        authorize(@provider, :can_create_course?)

        code = course_params[:accredited_provider_code]
        query = @accredited_provider

        @errors = errors_for_search_query(code, query)

        if @errors.present?
          render :new
        elsif other_selected_with_no_autocompleted_code?(code)
          redirect_to(
            search_new_publish_provider_recruitment_cycle_courses_accredited_provider_path(
              query: @accredited_provider,
              course: course_params
            )
          )
        else
          params[:course][:accredited_provider_code] = @autocompleted_provider_code if @autocompleted_provider_code.present?
          super
        end
      end

      def search_new
        authorize(provider, :can_create_course?)

        # These are not before_action hooks as they conflict with hooks
        # defined within the CourseBasicDetailConcern and cannot be overridden
        # without causing failures in other routes in this controller
        build_new_course
        build_provider
        build_previous_course_creation_params
        @query = params[:query]
        @provider_suggestions = recruitment_cycle.providers.with_findable_courses.provider_search(@query).limit(10)
      end

      def update
        build_provider
        begin
          code = update_course_params[:accredited_provider_code]
          query = update_course_params[:accredited_provider]
        rescue ActionController::ParameterMissing
          @errors = errors_for_search_query(code, query)
          return render :edit if @errors.present?
        end

        if update_params[:accredited_provider_code] == 'other'
          redirect_to_provider_search
        elsif @course.update(update_params)
          course_updated_message('Accredited provider')
          redirect_to_update_successful
        else
          @errors = @course.errors.messages
          render :edit
        end
      end

      def search
        build_course
        @query = params[:query]
        @provider_suggestions = recruitment_cycle.providers.with_findable_courses.provider_search(@query).limit(10)
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

      def redirect_to_provider_search
        redirect_to(
          accredited_provider_search_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
            query: update_course_params[:accredited_provider]
          )
        )
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

      def build_course_params
        @accredited_provider = params[:course].delete(:accredited_provider)
        @autocompleted_provider_code = params[:course].delete(:autocompleted_provider_code)
      end

      def errors_for_search_query(code, query)
        errors = {}

        if other_selected_with_no_autocompleted_code?(code) && query.length < 2
          errors = { accredited_provider: ['Accredited provider search too short, enter 2 or more characters'] }
        elsif code.blank?
          errors = { accredited_provider_code: ['Select an accredited provider'] }
        end

        errors
      end

      def update_course_params
        params.require(:course).permit(
          :autocompleted_provider_code,
          :accredited_provider_code,
          :accredited_provider
        )
      end

      def update_params
        autocompleted_code = update_course_params[:autocompleted_provider_code]
        code = update_course_params[:accredited_provider_code]

        {
          accredited_provider_code: autocompleted_code.presence || code
        }
      end

      def other_selected_with_no_autocompleted_code?(code)
        code == 'other' && @autocompleted_provider_code.blank?
      end

      def build_course
        super
        authorize @course
      end
    end
  end
end
