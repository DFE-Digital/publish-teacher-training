# frozen_string_literal: true

module Publish
  class CourseStudySiteForm < BaseCourseForm
    FIELDS = %i[study_site_ids].freeze

    attr_accessor(*FIELDS)

    validate :no_study_sites_selected

    private

    def compute_fields
      { study_site_ids: course.study_site_ids }.merge(new_attributes)
    end

    def no_study_sites_selected
      return if params[:study_site_ids].present?

      errors.add(:study_site_ids, :blank)
    end
  end
end
