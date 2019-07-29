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
      age_range_in_years: age_range_in_years
    }
  end
end
