# frozen_string_literal: true

# Display rules for the list of schools a provider can attach to a course.
#
# Shared by the two school pickers - Publish::CourseSchoolForm (course schools
# edit page) and CourseWizard::Steps::Schools (add course wizard) - so the two
# lists collapse at the same point.
module SchoolsList
  # Longer lists show only this many schools, behind a "Show all schools" link.
  # Kept in step with the show-all-schools Stimulus controller's `visible` value,
  # which both views pass explicitly.
  COLLAPSE_AFTER = 20
end
