# frozen_string_literal: true

# Publish-context replacement for `validates :sites, presence: true`.
# Reads the "course has at least one school" decision through
# Courses::PublishRules::SchoolPresence so flag-on reads from the
# Course::School model instead of the legacy Site association.
class CoursePublishableSchoolsPresenceValidator < ActiveModel::Validator
  def validate(course)
    return if Courses::PublishRules::SchoolPresence.any?(course)
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
