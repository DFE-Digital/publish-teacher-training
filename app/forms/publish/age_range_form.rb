# frozen_string_literal: true

module Publish
  class AgeRangeForm < BaseModelForm
    alias_method :course, :model

    include ::Courses::EditOptions::AgeRangeConcern

    FIELDS = %i[
      age_range_in_years
      course_age_range_in_years_other_from
      course_age_range_in_years_other_to
    ].freeze

    attr_accessor(*FIELDS)

    def course_age_range_in_years_other_from=(value)
      @course_age_range_in_years_other_from = if value.present?
                                                value.to_i
                                              else
                                                value
                                              end
    end

    def course_age_range_in_years_other_to=(value)
      @course_age_range_in_years_other_to = if value.present?
                                              value.to_i
                                            else
                                              value
                                            end
    end

    def initialize(model, params: nil)
      super
      return unless process_custom_range?

      self.course_age_range_in_years_other_from = extract_from_years
      self.course_age_range_in_years_other_to = extract_to_years
      self.age_range_in_years = "other"
    end

    validates :age_range_in_years, presence: true
    # Conditional validation to fix form validation
    with_options if: :age_range_other? do
      validates :course_age_range_in_years_other_from, numericality: {
        only_integer: true,
        allow_blank: true,
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 46,
      }
      validates :course_age_range_in_years_other_to, numericality: {
        only_integer: true,
        allow_blank: true,
        greater_than_or_equal_to: 4,
        less_than_or_equal_to: 50,
      }
      validate :age_range_from_and_to_missing
      validate :age_range_from_and_to_reversed
      validate :age_range_spans_at_least_4_years
    end

  private

    def age_range_other?
      age_range_in_years == "other"
    end

    def presets
      course.age_range_options
    end

    def compute_fields
      course.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def process_custom_range?
      age_range_in_years.present? && age_range_in_years != "other" && presets.exclude?(age_range_in_years)
    end

    def extract_from_years
      age_range_in_years.split("_").first
    end

    def extract_to_years
      age_range_in_years.split("_").last
    end

    def age_range_from_and_to_missing
      return unless age_range_in_years == "other"

      errors.add(:course_age_range_in_years_other_from, :blank) if course_age_range_in_years_other_from.blank?

      errors.add(:course_age_range_in_years_other_to, :blank) if course_age_range_in_years_other_to.blank?
    end

    def age_range_from_and_to_reversed
      errors.add(:course_age_range_in_years_other_from, :invalid) if age_range_in_years == "other" && course_age_range_in_years_other_from.present? && course_age_range_in_years_other_to.present? && (course_age_range_in_years_other_from.to_i > course_age_range_in_years_other_to.to_i)
    end

    def age_range_spans_at_least_4_years
      errors.add(:course_age_range_in_years_other_to, :invalid) if age_range_in_years == "other" && ((course_age_range_in_years_other_to.to_i - course_age_range_in_years_other_from.to_i).abs < 4)
    end
  end
end
