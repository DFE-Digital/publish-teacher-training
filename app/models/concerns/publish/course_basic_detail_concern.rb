# frozen_string_literal: true

module Publish
  module CourseBasicDetailConcern
    extend ActiveSupport::Concern

    included do
      decorates_assigned :course
      before_action :build_course, only: %i[edit update]
    end

    def edit
      authorize(provider)
    end

    def update
      authorize(provider)

      @errors = errors
      return render :edit if @errors.present?

      if @course.update(course_params)
        course_updated_message(section_key)

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

    def build_course
      @course = provider.courses.find_by!(course_code: params[:code])
    end

    def errors
      @course.errors.messages.slice(*error_keys)
    end

    def error_keys
      []
    end

    def course_params
      if params.key? :course
        params.require(:course)
              .except(
                :day,
                :month,
                :year,
                :course_age_range_in_years_other_from,
                :course_age_range_in_years_other_to,
              ).permit(
                policy(Course.new).permitted_new_course_attributes,
                study_mode: [],
                sites_ids: [],
                subjects_ids: [],
                study_sites_ids: [],
              )
      else
        ActionController::Parameters.new({}).permit(:course)
      end
    end
  end
end
