module Publish
  class CourseFeeForm < BaseProviderForm
    alias_method :course_enrichment, :model

    FIELDS = %i[
      course_length
      course_length_other_length
      fee_uk_eu
      fee_international
      fee_details
      financial_support
    ].freeze

    attr_accessor(*FIELDS)

    delegate :recruitment_cycle_year, :provider_code, :name, to: :course

    validates :course_length, presence: true
    validates :fee_uk_eu, presence: true, if: :is_fee_based?

    validates :fee_uk_eu,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 0,
                              less_than_or_equal_to: 100000 },
              if: :is_fee_based?

    validates :fee_international,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 0,
                              less_than_or_equal_to: 100000 },
              if: :is_fee_based?

    validates :fee_details, words_count: { maximum: 250, message: :too_long }, if: :is_fee_based?
    validates :financial_support, words_count: { maximum: 250, message: :too_long }, if: :is_fee_based?

    def other_course_length?
      course_length_is_other?(course_length)
    end

  private

    def is_fee_based?
      course&.is_fee_based?
    end

    def compute_fields
      course_enrichment
        .attributes
        .symbolize_keys
        .slice(*FIELDS)
        .merge(new_attributes)
        .merge(**hydrate_other_course_length)
        .symbolize_keys
    end

    def hydrate_other_course_length
      return {} unless course_length_is_other?(course_enrichment[:course_length])

      {
        course_length: "Other",
        course_length_other_length: course_enrichment[:course_length],
      }
    end

    def fields_to_ignore_before_save
      [:course_length_other_length]
    end

    def course
      course_enrichment.course
    end

    def course_length_is_other?(value)
      value.presence && %w[OneYear TwoYears].exclude?(value)
    end
  end
end
