# frozen_string_literal: true

# Checks every school the provider submitted became a Course::School. The
# resolver drops UUIDs that do not belong to the provider, so without this a
# course could save with fewer schools than were picked, or none at all.
class CourseSchoolSelectionValidator < ActiveModel::Validator
  def validate(course)
    submitted = submitted_uuids(course)

    # nil means the course was not built from submitted UUIDs, and empty means
    # nothing was chosen - that is CoursePublishableSchoolsPresenceValidator's
    # business, and it words the error as "Select at least one school" rather
    # than sending the provider to support.
    return if submitted.blank?
    return if submitted == school_uuids(course)

    course.errors.add(
      :schools,
      message: "^#{I18n.t('course_schools.errors.unrecognised_school_uuids', support_email: Settings.support_email)}",
    )
  end

private

  def submitted_uuids(course)
    course.submitted_school_uuids&.compact_blank&.map(&:to_s)&.to_set
  end

  def school_uuids(course)
    course.schools.filter_map { |school| school.provider_school&.uuid&.to_s }.to_set
  end
end
