module Courses
  class ValidateCustomAgeRangeService
    def execute(age_range_in_years, course)
      error_message = "#{age_range_in_years} is invalid. You must enter a valid age range."
      valid_regex_pattern = Regexp.new(/^(?<from>\d{1,2})_to_(?<to>\d{1,2})$/)

      if valid_regex_pattern.match(age_range_in_years)
        from_age = get_ages(age_range_in_years, valid_regex_pattern)["from"]
        to_age = get_ages(age_range_in_years, valid_regex_pattern)["to"]
      end

      if !valid_regex_pattern.match(age_range_in_years)
        course.errors.add(:age_range_in_years, error_message)
      elsif from_age_invalid?(from_age)
        course.errors.add(:age_range_in_years, error_message)
      elsif to_age_invalid?(to_age)
        course.errors.add(:age_range_in_years, error_message)
      elsif to_age - from_age < 4
        course.errors.add(:age_range_in_years, "#{age_range_in_years} is invalid. Your age range must cover at least 4 years.")
      end
    end

  private

    def get_ages(age_range_in_years, valid_regex_pattern)
      valid_regex_pattern.match(age_range_in_years)&.named_captures&.transform_values { |v| v.to_i }
    end

    def from_age_invalid?(from_age)
      from_age < 3 || from_age > 14
    end

    def to_age_invalid?(to_age)
      to_age < 7 || to_age > 18
    end
  end
end
