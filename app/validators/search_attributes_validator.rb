# frozen_string_literal: true

# Single source of truth for allowed search filter keys.
# Shared by RecentSearch and EmailAlert model validation.
# Derived from Courses::SearchForm and ResultsController#search_courses_params.
class SearchAttributesValidator < ActiveModel::EachValidator
  PERMITTED_KEYS = %w[
    applications_open
    can_sponsor_visa
    engineers_teach_physics
    formatted_address
    funding
    level
    location
    minimum_degree_required
    order
    provider_code
    provider_name
    qualifications
    radius
    send_courses
    start_date
    study_types
    subject_code
  ].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    unknown_keys = value.keys - PERMITTED_KEYS
    if unknown_keys.any?
      record.errors.add(attribute, "contains unknown keys: #{unknown_keys.join(', ')}")
    end
  end
end
