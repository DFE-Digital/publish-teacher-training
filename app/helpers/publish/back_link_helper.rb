# frozen_string_literal: true

module Publish
  module BackLinkHelper
    def visa_path(course)
      if previously_basic_details?
        details_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code
        )
      elsif previously_tda_course?
        full_part_time_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code,
          previous_tda_course: true
        )
      elsif course.provider.accredited_provider?
        apprenticeship_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code
        )
      else
        funding_type_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code
        )
      end
    end

    def study_mode_path(course)
      if previously_tda_course?
        funding_type_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code,
          previous_tda_course: true
        )
      else

        details_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code
        )

      end
    end

    private

    def previously_tda_course?
      params[:previous_tda_course] == 'true'
    end

    def previously_basic_details?
      params[:back_to_basic_details].present?
    end
  end
end
