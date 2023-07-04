# frozen_string_literal: true

module Publish
  class CourseFeeForm < BaseModelForm
    include RecruitmentCycleHelper

    alias course_enrichment model

    include FundingTypeFormMethods

    FIELDS = %i[
      course_length
      course_length_other_length
      fee_uk_eu
      fee_international
      fee_details
      financial_support
    ].freeze

    attr_accessor(*FIELDS)

    validates :course_length, presence: true
    validates :fee_uk_eu, presence: true
    validates :fee_international, presence: true, if: -> { student_visa_and_after_2023_cycle(course) }

    validates :fee_uk_eu,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 0,
                              less_than_or_equal_to: 100_000 }

    validates :fee_international,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 0,
                              less_than_or_equal_to: 100_000 }

    validates :fee_details, words_count: { maximum: 250, message: :too_long }
    validates :financial_support, words_count: { maximum: 250, message: :too_long }

    private

    def declared_fields
      FIELDS
    end

    def student_visa_and_after_2023_cycle(course)
      course.can_sponsor_student_visa? && recruitment_cycle_after_2023?(course)
    end
  end
end
