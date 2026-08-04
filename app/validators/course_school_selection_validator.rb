# frozen_string_literal: true

# Checks a course's school selection survived the write intact: everything the
# provider submitted became a legacy Site, and every Site got the Course::School
# the dual write owes it.
#
# TODO School data remodel removal - delete once courses only write Course::School.
class CourseSchoolSelectionValidator < ActiveModel::Validator
  def validate(course)
    submitted = submitted_uuids(course)
    sites = site_uuids(course)

    # Nothing chosen at all - that is CoursePublishableSchoolsPresenceValidator's
    # business, and it words the error as "Select at least one school" rather
    # than sending the provider to support.
    return if submitted.blank? && sites.empty?

    # nil (rather than empty) means the course was not built from submitted
    # UUIDs - the legacy sites_ids path - so there is no submission to hold the
    # sites to, and only the dual write itself gets checked.
    expected = submitted || sites
    return if expected == sites && expected == school_uuids(course)

    course.errors.add(
      :schools,
      message: "^#{I18n.t('course_schools.errors.unrecognised_school_uuids', support_email: Settings.support_email)}",
    )
  end

private

  def submitted_uuids(course)
    uuids = course.submitted_school_uuids
    return if uuids.nil?

    uuids.compact_blank.map(&:to_s).to_set
  end

  def site_uuids(course)
    course.sites.filter_map { |site| site.uuid&.to_s }.to_set
  end

  # Read through provider_school rather than the denormalised gias_school_id:
  # uuid is the key the legacy site and its Provider::School actually share.
  def school_uuids(course)
    course.schools.filter_map { |school| school.provider_school&.uuid&.to_s }.to_set
  end
end
