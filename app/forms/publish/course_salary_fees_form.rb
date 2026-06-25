# frozen_string_literal: true

module Publish
  class CourseSalaryFeesForm < BaseModelForm
    alias_method :course_enrichment, :model

    FIELDS = %i[salary_fee_details].freeze

    attr_accessor(*FIELDS)

    validates :salary_fee_details, words_count: { maximum: 250, message: :too_long }

  private

    def declared_fields
      FIELDS
    end

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
