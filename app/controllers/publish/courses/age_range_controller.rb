module Publish
  module Courses
    class AgeRangeController < PublishController
      include CourseBasicDetailConcern
      decorates_assigned :course
      before_action :build_recruitment_cycle, only: %i[edit update]
      before_action :build_provider, only: %i[edit update]
      before_action :build_course, only: %i[edit update]

      def edit
        if params[:display_errors] == "true"
          form_object.valid?
        end

        render locals: { form_object: form_object }
      end

      def update
        if form_object.valid?
          flash[:success] = I18n.t("success.saved")

          update_age_range_param

          if @course.update(course_params)
            redirect_to(
              details_publish_provider_recruitment_cycle_course_path(
                @course.provider_code,
                @course.recruitment_cycle_year,
                @course.course_code,
              ),
            )
          end
        else
          render :edit, locals: { form_object: form_object }
        end
      end

    private

      def age_range_presets
        @course.edit_course_options['age_range_in_years']
      end

      def form_object
        @form_object ||= AgeRangeForm.new(@course, params: permitted_params)
      end

      def permitted_params
        if params[:course]
          (params[:course] || ActionController::Parameters.new).permit(:age_range_in_years, :course_age_range_in_years_other_from, :course_age_range_in_years_other_to)
        else
          @course.attributes.select { |k, _v| %w[age_range_in_years course_age_range_in_years_other_from course_age_range_in_years_other_to].include?(k) }
        end
      end

      def error_keys
        [:age_range_in_years]
      end

      def update_age_range_param
        params[:course][:age_range_in_years] = "#{age_from_param}_to_#{age_to_param}" if valid_custom_age_range?
      end

      def valid_custom_age_range?
        age_from_param.present? && age_to_param.present? && age_range_is_other?
      end

      def age_to_param
        course_param[:course_age_range_in_years_other_to]
      end

      def age_from_param
        course_param[:course_age_range_in_years_other_from]
      end

      def age_range_param
        course_param[:age_range_in_years]
      end

      def age_range_is_other?
        age_range_param == "other"
      end

      def course_param
        params[:course]
      end

      def current_step
        :age_range
      end

      def build_provider
        return if params[:provider_code].blank?

        @provider = @recruitment_cycle.providers.find_by!(
          provider_code: params[:provider_code].upcase,
        )
      end

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def build_course
        @course = @provider.courses.find_by!(course_code: params[:code].upcase)

        authorize @course
      end
    end
  end
end
