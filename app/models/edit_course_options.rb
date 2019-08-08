class EditCourseOptions
  def initialize(course)
    @course = course
  end

  def entry_requirements
    Course::ENTRY_REQUIREMENT_OPTIONS
      .reject { |k, _v| %i[not_set not_required].include?(k) }
      .keys
  end

  def qualifications
    qualifications_with_qts, qualifications_without_qts = Course::qualifications.keys.partition { |q| q.include?('qts') }
    @course.level == :further_education ? qualifications_without_qts : qualifications_with_qts
  end

  def age_range_in_years
    case @course.level
    when :primary
      %w[
        3_to_7
        5_to_11
        7_to_11
        7_to_14
      ]
    when :secondary
      %w[
        11_to_16
        11_to_18
        14_to_19
      ]
    end
  end

  def all
    {
      entry_requirements: entry_requirements,
      qualifications: qualifications,
      age_range_in_years: age_range_in_years,
      start_dates: start_dates
    }
  end

  def start_dates
    recruitment_year = @course.provider.recruitment_cycle.year.to_i

    dates = ["August #{recruitment_year}",
             "September #{recruitment_year}",
             "October #{recruitment_year}",
             "November #{recruitment_year}",
             "December #{recruitment_year}",
             "January #{recruitment_year + 1}",
             "February #{recruitment_year + 1}",
             "March #{recruitment_year + 1}",
             "April #{recruitment_year + 1}",
             "May #{recruitment_year + 1}",
             "June #{recruitment_year + 1}",
             "July #{recruitment_year + 1}"]
  end
end
