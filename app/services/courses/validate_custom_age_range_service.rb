# frozen_string_literal: true

module Courses
  class ValidateCustomAgeRangeService
    AGE_RANGE_REGEX = /^(?<from>\d{1,2})_to_(?<to>\d{1,2})$/
    MIN_FROM_AGE = 3
    MAX_FROM_AGE = 15
    MIN_TO_AGE = 7
    MAX_TO_AGE = 19
    MIN_AGE_SPAN = 4

    def execute(age_range_in_years, course)
      ages = parse_age_range(age_range_in_years)

      if ages.nil?
        course.errors.add(:age_range_in_years, "^Enter an age range")
        return
      end

      from_age, to_age = ages.values_at("from", "to")

      if invalid_from_age?(from_age) || invalid_to_age?(to_age)
        course.errors.add(:age_range_in_years, "^Age range must cover #{MIN_AGE_SPAN} or more school years")
      elsif (to_age - from_age) < MIN_AGE_SPAN
        course.errors.add(:age_range_in_years, "^Age range must cover at least #{MIN_AGE_SPAN} years")
      end
    end

  private

    def parse_age_range(age_range)
      AGE_RANGE_REGEX.match(age_range)&.named_captures&.transform_values(&:to_i)
    end

    def invalid_from_age?(age)
      age < MIN_FROM_AGE || age > MAX_FROM_AGE
    end

    def invalid_to_age?(age)
      age < MIN_TO_AGE || age > MAX_TO_AGE
    end
  end
end
