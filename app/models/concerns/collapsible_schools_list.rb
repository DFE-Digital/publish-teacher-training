# frozen_string_literal: true

# Long school lists are collapsed to the first COLLAPSE_AFTER rows, with a
# "Show all schools" link revealing the rest.
#
# Included by the objects backing the two school pickers - Publish::CourseSchoolForm
# (course schools edit page) and CourseWizard::Steps::Schools (add course wizard) -
# so both share one collapse rule. Includers must expose #sites.
module CollapsibleSchoolsList
  COLLAPSE_AFTER = 20

  def schools_collapse_threshold
    COLLAPSE_AFTER
  end

  def collapse_schools?
    sites.size > schools_collapse_threshold
  end
end
