module Courses
  class ValidateCustomAgeRangeService
    def execute(age_range_in_years, course)
      valid_age_range_regex = Regexp.new(/^(?<from>\d{1,2})_to_(?<to>\d{1,2})$/)

      if valid_age_range_regex.match(age_range_in_years)
        from_age = get_ages(age_range_in_years, valid_age_range_regex)["from"]
        to_age = get_ages(age_range_in_years, valid_age_range_regex)["to"]
        if from_age_invalid?(from_age) || to_age_invalid?(to_age)
          course.errors.add(:age_range_in_years, "^Age range must be a school age")
        elsif to_age - from_age < 4
          course.errors.add(:age_range_in_years, "^Age range must cover at least 4 years")
        end
      else
        course.errors.add(:age_range_in_years, "^Enter an age range")
      end
    end

  private

    def get_ages(age_range_in_years, valid_age_range_regex)
      valid_age_range_regex.match(age_range_in_years)&.named_captures&.transform_values(&:to_i)
    end

    def from_age_invalid?(from_age)
      from_age < 3 || from_age > 15
    end

    def to_age_invalid?(to_age)
      to_age < 7 || to_age > 19
    end
  end
end
