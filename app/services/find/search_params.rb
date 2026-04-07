# frozen_string_literal: true

module Find
  class SearchParams
    PERMITTED = [
      :applications_open,
      :can_sponsor_visa,
      :engineers_teach_physics,
      :formatted_address,
      :funding,
      :interview_location,
      :latitude,
      :level,
      :location,
      :longitude,
      :minimum_degree_required,
      :order,
      :previous_location_category,
      :provider_code,
      :provider_name,
      :radius,
      :return_to,
      :send_courses,
      :subject_code,
      :subject_name,
      { subjects: [],
        start_date: [],
        study_types: [],
        qualifications: [],
        funding: [],
        excluded_courses: %i[provider_code course_code] },
    ].freeze

    def self.permit(params)
      permitted = PERMITTED.dup

      permitted.delete(:applications_open) if FeatureFlag.active?(:hide_applications_open_date)

      params.permit(*permitted)
    end
  end
end
