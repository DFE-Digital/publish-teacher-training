# frozen_string_literal: true

# Display rules for the list of schools a provider can attach to a course.
#
# Shared by the two school pickers - Publish::CourseSchoolForm (course schools
# edit page) and CourseWizard::Steps::Schools (add course wizard) - so the two
# lists collapse at the same point.
module SchoolsList
  # Longer lists show only this many schools, behind a "Show all schools" link.
  # Kept in step with the schools-list Stimulus controller's `collapseAfter`
  # value, which both views pass explicitly.
  COLLAPSE_AFTER = 20

  # Every school the provider could attach, in the order they are listed. The
  # bulk update pages read it too: what they play back has to be measured
  # against the same list the provider ticked.
  def self.for(provider)
    provider.schools.includes(:gias_school).order("gias_school.name")
  end
end
