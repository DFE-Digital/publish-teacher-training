module Publish
  class CourseSalaryForm < BaseModelForm
    alias_method :course_enrichment, :model

    include FundingTypeFormMethods

    FIELDS = %i[
      course_length
      course_length_other_length
      salary_details
    ].freeze

    attr_accessor(*FIELDS)

    validates :course_length, presence: true
    validates :salary_details, presence: true
    validates :salary_details, words_count: { maximum: 250, message: :too_long }

  private

    def declared_fields
      FIELDS
    end
  end
end
