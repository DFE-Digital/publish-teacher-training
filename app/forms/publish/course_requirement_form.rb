module Publish
  class CourseRequirementForm < BaseModelForm
    alias_method :course_enrichment, :model

    FIELDS = %i[
      personal_qualities
      other_requirements
    ].freeze

    attr_accessor(*FIELDS)

    validates :personal_qualities, words_count: { maximum: 100,  message: :too_long }
    validates :other_requirements, words_count: { maximum: 100,  message: :too_long }

  private

    def compute_fields
      course_enrichment.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
