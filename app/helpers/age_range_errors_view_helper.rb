module AgeRangeErrorsViewHelper
  def expand_another_age_range?
    (course.other_age_range? && course.age_range_in_years.present?) ||
      (@errors && (@errors[:age_range_in_years_to].present? || @errors[:age_range_in_years_from].present?))
  end

  def age_range_from_field_value
    if course.other_age_range? && course.age_range_in_years.present?
      course.age_range_in_years.split("_").first
    else
      ""
    end
  end

  def age_range_to_field_value
    if course.other_age_range? && course.age_range_in_years.present?
      course.age_range_in_years.split("_").last
    else
      ""
    end
  end
end
