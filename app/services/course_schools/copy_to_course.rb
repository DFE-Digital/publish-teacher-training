# frozen_string_literal: true

# Copies a course's placement schools onto a copy of that course under another
# provider.
#
# Only copy course schools to the new provider if the new provider has the
# provider schools
module CourseSchools
  class CopyToCourse
    def call(course:, new_provider:, new_course:)
      schools_to_copy(course, new_provider).each do |provider_school|
        new_course.schools.create!(
          provider_school:,
          gias_school_id: provider_school.gias_school_id,
        )
      end
    end

  private

    def schools_to_copy(course, new_provider)
      new_provider.schools.where(gias_school_id: course.schools.select(:gias_school_id)).to_a
    end
  end
end
