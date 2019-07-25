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

  def all
    {
      entry_requirements: entry_requirements,
      qualifications: qualifications
    }
  end
end
