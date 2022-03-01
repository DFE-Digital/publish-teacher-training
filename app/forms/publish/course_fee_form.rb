module Publish
  class CourseFeeForm < BaseModelForm
    alias_method :course_enrichment, :model

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

    validates :fee_uk_eu,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 0,
                              less_than_or_equal_to: 100000 }

    validates :fee_international,
              numericality: { allow_blank: true,
                              only_integer: true,
                              greater_than_or_equal_to: 0,
                              less_than_or_equal_to: 100000 }

    validates :fee_details, words_count: { maximum: 250, message: :too_long }
    validates :financial_support, words_count: { maximum: 250, message: :too_long }

  private

    def declared_fields
      FIELDS
    end
  end
end
