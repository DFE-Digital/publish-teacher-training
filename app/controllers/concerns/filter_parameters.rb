# frozen_string_literal: true

module FilterParameters
  PREVIOUS_PARAMETER_PREFIX = 'prev_'

  def filter_params
    parameters.reject do |param|
      param.in? %w[utf8 authenticity_token page]
    end
  end

  def filter_params_without_previous_parameters
    remove_previous_parameters(filter_params)
  end

  def merge_previous_parameters(all_parameters)
    previous_parameters.each do |key, value|
      next if value == 'none'

      all_parameters[key.delete_prefix(PREVIOUS_PARAMETER_PREFIX)] = value
    end

    remove_previous_parameters(all_parameters)
  end

  private

  def parameters
    return request.query_parameters if %w[GET HEAD].include?(request.method)

    request.request_parameters
  end

  def previous_parameters
    parameters.select { |key, _value| key.start_with? PREVIOUS_PARAMETER_PREFIX }
  end

  def remove_previous_parameters(all_parameters)
    all_parameters.reject { |key, _value| key.start_with? PREVIOUS_PARAMETER_PREFIX }
  end

  def legacy_paramater_keys
    %i[
      fulltime
      hasvacancies
      lat
      lng
      parttime
      prev_l
      prev_lat
      prev_lng
      prev_loc
      prev_lq
      prev_query
      prev_rad
      qualifications
      query
      rad
      senCourses
    ]
  end

  def form_params
    # Some legacy keys are whitelisted here as they can accept multiple values
    params
      .require(form_name)
      .permit(
        *legacy_paramater_keys,
        :age_group,
        :c,
        :can_sponsor_visa,
        :degree_required,
        :engineers_teach_physics,
        :funding,
        :has_vacancies,
        :applications_open,
        :l,
        :latitude,
        :loc,
        :long,
        :longitude,
        :lq,
        :radius,
        :send_courses,
        :sortby,
        'provider.provider_name',
        c: [],
        qualification: [],
        qualifications: [], # Legacy
        study_type: [],
        subjects: [],
        subject_codes: [] # Legacy
      )
  end
end
