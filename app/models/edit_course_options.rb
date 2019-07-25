class EditCourseOptions
  def initialize(course)
    @course = course
  end

  def entry_requirements
    Course::ENTRY_REQUIREMENT_OPTIONS
      .reject { |k, _v| %i[not_set not_required].include?(k) }
      .keys
  end
end
