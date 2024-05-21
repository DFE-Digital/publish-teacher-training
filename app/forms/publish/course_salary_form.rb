# frozen_string_literal: true

module Publish
  class CourseSalaryForm < BaseModelForm
    alias course_enrichment model

    include FundingTypeFormMethods

    FIELDS = %i[salary_details].freeze

    attr_accessor(*FIELDS)

    validates :salary_details, presence: true
    validates :salary_details, words_count: { maximum: 250, message: :too_long }

    private

    def declared_fields
      FIELDS
    end
  end
end
