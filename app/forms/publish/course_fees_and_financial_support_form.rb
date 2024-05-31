# frozen_string_literal: true

module Publish
  class CourseFeesAndFinancialSupportForm < BaseModelForm
    include RecruitmentCycleHelper
    include FundingTypeFormMethods

    alias course_enrichment model

    FIELDS = %i[fee_details].freeze

    attr_accessor(*FIELDS)

    validates :fee_details, words_count: { maximum: 250, message: :too_long }

    private

    def declared_fields
      FIELDS
    end
  end
end
