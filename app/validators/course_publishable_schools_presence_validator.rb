# frozen_string_literal: true

# Publish-context replacement for `validates :sites, presence: true`.
# Reads the "course has at least one school" decision through
# Courses::PublishRules::SchoolPresence so flag-on reads from the
# Course::School model instead of the legacy Site association.
class CoursePublishableSchoolsPresenceValidator < ActiveModel::Validator
  def validate(course)
    return if Courses::PublishRules::SchoolPresence.any?(course)

    course.errors.add(:sites, :blank)
  end
end
