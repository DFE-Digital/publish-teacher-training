module Publish
  class CourseRequirementForm < BaseModelForm
    alias_method :course_enrichment, :model

    FIELDS = %i[
      required_qualifications
      personal_qualities
      other_requirements
    ].freeze

    attr_accessor(*FIELDS)

    validates :required_qualifications, presence: true, if: :required_qualifications_needed?
    validates :required_qualifications, words_count: { maximum: 100, message: :too_long }
    validates :personal_qualities, words_count: { maximum: 100,  message: :too_long }
    validates :other_requirements, words_count: { maximum: 100,  message: :too_long }

  private

    def compute_fields
      course_enrichment.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def required_qualifications_needed?
      (course_enrichment.course&.provider&.recruitment_cycle&.year.to_i) < Course::STRUCTURED_REQUIREMENTS_REQUIRED_FROM
    end
  end
end
