# frozen_string_literal: true

# Publish-context rollover rule for the 2026 recruitment-cycle migration:
# when a provider's rolled-over course hits Publish, they must explicitly
# re-confirm their schools (the `schools_validated` column). Until they
# do, publishing is blocked with one of two error keys depending on
# whether any school is currently attached.
#
# Reads the "course has at least one school" decision through
# Courses::PublishRules::SchoolPresence so flag-on reads from the
# Course::School model instead of the legacy Site association.
class CoursePublishableSchoolsRolloverValidator < ActiveModel::Validator
  def validate(course)
    return if course.schools_validated?
    return unless course.latest_enrichment&.rolled_over?

    if Courses::PublishRules::SchoolPresence.any?(course)
      course.errors.add(:sites, :check_schools)
    else
      course.errors.add(:sites, :enter_schools)
    end
  end
end
