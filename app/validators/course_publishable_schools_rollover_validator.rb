# frozen_string_literal: true

# Publish-context rollover rule for the 2026 recruitment-cycle migration:
# when a provider's rolled-over course hits Publish, they must explicitly
# re-confirm their schools (the `schools_validated` column). Until they
# do, publishing is blocked with one of two error keys depending on
# whether any school is currently attached.
#
# School presence is read from the Course::School association.
class CoursePublishableSchoolsRolloverValidator < ActiveModel::Validator
  def validate(course)
    return if course.schools_validated?
    return unless course.latest_enrichment&.rolled_over?

    if course.schools.any?
      course.errors.add(:sites, :check_schools)
    elsif !Courses::PublishRules::SchoolPresenceExemption.applies?(course)
      course.errors.add(:sites, :enter_schools)
    end
  end
end
