# frozen_string_literal: true

module Publish
  class CourseSchoolPlacementsForm < BaseProviderForm
    alias_method :course_enrichment, :model

    FIELDS = %i[how_school_placements_work].freeze

    attr_accessor(*FIELDS)

    delegate :recruitment_cycle_year, :provider_code, :name, to: :course

    validates :how_school_placements_work, presence: true
    validates :how_school_placements_work, words_count: { maximum: 350, message: :too_long }

    def save!
      if valid?
        assign_attributes_to_model
        course_enrichment.status = :draft if course_enrichment.rolled_over?
        course_enrichment.save!
      else
        false
      end
    end

  private

    def compute_fields
      course_enrichment.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
