module Publish
  class CourseInformationForm < BaseProviderForm
    alias_method :course_enrichment, :model

    FIELDS = %i[
      about_course
      interview_process
      how_school_placements_work
    ].freeze

    attr_accessor(*FIELDS)

    delegate :recruitment_cycle_year, :provider_code, :name, to: :course

    validates :about_course, presence: true
    validates :about_course, words_count: { maximum: 400, message: :too_long }

    validates :interview_process, words_count: { maximum: 250, message: :too_long }

    validates :how_school_placements_work, presence: true
    validates :how_school_placements_work, words_count: { maximum: 350, message: :too_long }

  private

    def compute_fields
      course_enrichment.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
