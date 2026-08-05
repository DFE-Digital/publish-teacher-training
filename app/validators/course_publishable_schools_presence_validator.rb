# frozen_string_literal: true

# Publish-context replacement for `validates :sites, presence: true`.
# School presence is read from the Course::School association.
class CoursePublishableSchoolsPresenceValidator < ActiveModel::Validator
  def validate(course)
    return if course.schools.any?
    return if Courses::PublishRules::SchoolPresenceExemption.applies?(course)
    return if selection_made_but_unresolved?(course)

    course.errors.add(:sites, :blank)
  end

private

  # The provider did choose schools, they just did not survive the write.
  # CourseSchoolSelectionValidator says so properly; "Select at least one school"
  # would send them back to re-pick what they already picked. Always false on
  # :publish, where the accessor is nil because it is never persisted.
  def selection_made_but_unresolved?(course)
    course.submitted_school_uuids&.compact_blank&.any? || false
  end
end
