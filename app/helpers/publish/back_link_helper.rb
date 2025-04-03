# frozen_string_literal: true

module Publish
  module BackLinkHelper
    def visa_path(course)
      if previously_basic_details?
        details_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code,
        )
      elsif previously_tda_course?
        full_part_time_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code,
          previous_tda_course: true,
        )
      else
        funding_type_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code,
        )
      end
    end

    def study_mode_path(course)
      if previously_tda_course?
        funding_type_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code,
          previous_tda_course: true,
        )
      else

        details_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code,
        )

      end
    end

    def accredited_provider_search_path(param_form_key:, params:, provider:, recruitment_cycle_year:)
      publish_back_link_for_adding_provider_partnership_path(param_form_key:, params:, recruitment_cycle_year:, provider:)
    end

  private

    def previously_tda_course?
      params[:previous_tda_course] == "true"
    end

    def previously_basic_details?
      params[:back_to_basic_details].present?
    end
  end
end
