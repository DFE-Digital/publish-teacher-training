# frozen_string_literal: true

module Publish
  class CourseFeeForm < BaseModelForm
    include RecruitmentCycleHelper

    alias_method :course_enrichment, :model

    include FundingTypeFormMethods

    FIELDS = %i[
      fee_uk_eu
      fee_international
      fee_details
      financial_support
    ].freeze

    attr_accessor(*FIELDS)

    validates :fee_uk_eu, presence: true
    validates :fee_international, presence: true, if: -> { course.can_sponsor_student_visa? }

    validates :fee_uk_eu,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 1,
                              less_than_or_equal_to: 100_000 }

    validates :fee_international,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 1,
                              less_than_or_equal_to: 100_000 }

    validates :fee_details, words_count: { maximum: 250, message: :too_long }
    validates :financial_support, words_count: { maximum: 250, message: :too_long }

  private

    def declared_fields
      FIELDS
    end
  end
end
