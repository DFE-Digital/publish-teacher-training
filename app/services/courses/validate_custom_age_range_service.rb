module Courses
  class ValidateCustomAgeRangeService
    def execute(age_range_in_years, course)
      # This regex checks that a 1 or 2 digit number is selected for the 'to' and 'from' values.
      # It also checks that the age range is correctly formatted with _to_ in between these values
      valid_regex_pattern = /^(\d{1,2})_to_(\d{1,2})$/
      #The below grabs the 'from' and 'to' ages and puts them into variables if the regex is valid
      from_age, to_age = valid_regex_pattern.match(age_range_in_years).captures if valid_regex_pattern.match(age_range_in_years)

      error_message = "#{age_range_in_years} is invalid. You must enter a valid age range."

      if !valid_regex_pattern.match(age_range_in_years)
        course.errors.add(:age_range_in_years, error_message)
      elsif from_age_invalid?(from_age)
        course.errors.add(:age_range_in_years, error_message)
      elsif to_age_invalid?(to_age)
        course.errors.add(:age_range_in_years, error_message)
      elsif to_age.to_i - from_age.to_i < 4
        course.errors.add(:age_range_in_years, "#{age_range_in_years} is invalid. Your age range must cover at least 4 years.")
      end
    end

  private

    def from_age_invalid?(from_age)
      from_age.to_i < 3 || from_age.to_i > 14
    end

    def to_age_invalid?(to_age)
      to_age.to_i < 7 || to_age.to_i > 18
    end
  end
end
