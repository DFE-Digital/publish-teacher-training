module CourseSearchOptions
  attr_reader :sort, :filter

private

  def sort_set
    @sort_set ||= Set.new(sort&.split(","))
  end

  def sort_by_provider_ascending?
    sort_set == Set["name", "provider.provider_name"]
  end

  def sort_by_provider_descending?
    sort_set == Set["-name", "-provider.provider_name"]
  end

  def sort_by_distance?
    sort_set == Set["distance"]
  end

  def expand_university?
    filter[:expand_university].to_s.downcase == "true"
  end

  def locations_filter?
    filter.key?(:latitude) &&
      filter.key?(:longitude) &&
      filter.key?(:radius)
  end

  def origin
    [filter[:latitude], filter[:longitude]]
  end

  def funding_filter_salary?
    filter[:funding] == "salary"
  end

  def qualifications
    return [] if filter[:qualification].blank?

    filter[:qualification].split(",")
  end

  def has_vacancies?
    filter[:has_vacancies].to_s.downcase == "true"
  end

  def findable?
    filter[:findable].to_s.downcase == "true"
  end

  def study_types
    return [] if filter[:study_type].blank?

    filter[:study_type].split(",")
  end

  def funding_types
    return [] if filter[:funding_type].blank?

    filter[:funding_type].split(",")
  end

  def degree_grades
    return [] if filter[:degree_grade].blank?
    return [] unless filter[:degree_grade].is_a?(String)

    filter[:degree_grade].split(",")
  end

  def subject_codes
    return [] if filter[:subjects].blank?
    return [] unless filter[:subjects].is_a?(String)

    filter[:subjects].split(",")
  end

  def provider_name
    return [] if filter[:"provider.provider_name"].blank?

    filter[:"provider.provider_name"]
  end

  def send_courses_filter?
    filter[:send_courses].to_s.downcase == "true"
  end

  def updated_since_filter?
    filter[:updated_since].present?
  end

  def can_sponsor_visa_filter?
    filter[:can_sponsor_visa].to_s.downcase == "true"
  end
end
