# frozen_string_literal: true

module Publish
  module Fields
    class FeesAndFinancialSupportForm < BaseModelForm
      include RecruitmentCycleHelper
      include FundingTypeFormMethods

      alias_method :course_enrichment, :model
      delegate :is_fee_based?, :version, to: :course_enrichment

      FIELDS = %i[fee_uk_eu fee_international fee_schedule additional_fees financial_support].freeze

      attr_accessor(*FIELDS)

      validates :fee_schedule, words_count: { maximum: 50 }, if: :is_fee_based?
      validates :additional_fees, words_count: { maximum: 50 }, if: :is_fee_based?

      validates :financial_support,
                words_count: { maximum: 250 },
                if: -> { is_fee_based? && version.to_i == 1 }

      validates :financial_support,
                words_count: { maximum: 50 },
                if: -> { is_fee_based? && version.to_i == 2 }

      validates :fee_uk_eu, presence: true, if: :is_fee_based?
      validates :fee_uk_eu,
                numericality: { allow_blank: true,
                                only_integer: true,
                                greater_than_or_equal_to: 0,
                                less_than_or_equal_to: 100_000 },
                if: :is_fee_based?

      validates :fee_international, presence: true, if: -> { is_fee_based? && course.can_sponsor_student_visa? }
      validates :fee_international,
                numericality: { allow_blank: true,
                                only_integer: true,
                                greater_than_or_equal_to: 0,
                                less_than_or_equal_to: 100_000 },
                if: :is_fee_based?

    private

      def declared_fields
        FIELDS
      end
    end
  end
end
