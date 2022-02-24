module Publish
  module Courses
    class AccreditedBodyController < PublishController
      before_action :build_course_params, only: :continue
      include CourseBasicDetailConcern

      def edit
        build_provider
      end

      def continue
        authorize(@provider, :can_create_course?)

        code = course_params[:accredited_body_code]
        query = @accredited_body

        @errors = errors_for_search_query(code, query)

        if @errors.present?
          render :new
        elsif other_selected_with_no_autocompleted_code?(code)
          redirect_to(
            search_new_provider_recruitment_cycle_courses_accredited_body_path(
              query: @accredited_body,
              course: course_params,
            ),
          )
        else
          params[:course][:accredited_body_code] = @autocompleted_provider_code if @autocompleted_provider_code.present?
          super
        end
      end

      def search_new
        # These are not before_action hooks as they conflict with hooks
        # defined within the CourseBasicDetailConcern and cannot be overridden
        # without causing failures in other routes in this controller
        build_new_course
        build_provider
        build_previous_course_creation_params
        @query = params[:query]
        @provider_suggestions = ProviderSuggestion.suggest_any_accredited_body(@query)
      rescue JsonApiClient::Errors::ClientError => e
        @errors = e
      end

      def update
        build_provider
        code = update_course_params[:accredited_body_code]
        query = update_course_params[:accredited_body]

        @errors = errors_for_search_query(code, query)
        return render :edit if @errors.present?

        if update_params[:accredited_body_code] == "other"
          redirect_to_provider_search
        elsif @course.update(update_params)
          redirect_to_update_successful
        else
          @errors = @course.errors.messages
          render :edit
        end
      end

      def search
        build_course
        @query = params[:query]
        @provider_suggestions = ProviderSuggestion.suggest_any_accredited_body(@query)
      rescue JsonApiClient::Errors::ClientError => e
        @errors = e
      end

    private

      def build_provider
        @provider = RecruitmentCycle.find_by(year: params[:recruitment_cycle_year])
                      .providers
                      .find_by(provider_code: params[:provider_code])
      end

      def error_keys
        [:accredited_body_code]
      end

      def redirect_to_provider_search
        redirect_to(
          accredited_body_search_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
            query: update_course_params[:accredited_body],
          ),
        )
      end

      def redirect_to_update_successful
        flash[:success] = I18n.t("success.saved")
        redirect_to(
          details_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      end

      def current_step
        :accredited_body
      end

      def build_course_params
        @accredited_body = params[:course].delete(:accredited_body)
        @autocompleted_provider_code = params[:course].delete(:autocompleted_provider_code)
      end

      def errors_for_search_query(code, query)
        errors = {}

        if other_selected_with_no_autocompleted_code?(code) && query.length < 2
          errors = { accredited_body: ["Accredited body search too short, enter 2 or more characters"] }
        elsif code.blank?
          errors = { accredited_body_code: ["Pick an accredited body"] }
        end

        errors
      end

      def build_course
        @course = Course
          .where(recruitment_cycle_year: params[:recruitment_cycle_year])
          .where(provider_code: params[:provider_code])
          .includes(:accrediting_provider)
          .find(params[:code])
          .first
      end

      def update_course_params
        params.require(:course).permit(
          :autocompleted_provider_code,
          :accredited_body_code,
          :accredited_body,
        )
      end

      def update_params
        autocompleted_code = update_course_params[:autocompleted_provider_code]
        code = update_course_params[:accredited_body_code]

        {
          accredited_body_code: autocompleted_code.presence || code,
        }
      end

      def other_selected_with_no_autocompleted_code?(code)
        code == "other" && @autocompleted_provider_code.blank?
      end
    end
  end
end
