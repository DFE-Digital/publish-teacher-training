# frozen_string_literal: true

module Publish
  class CourseSchoolForm < BaseCourseForm
    FIELDS = %i[site_ids schools_validated].freeze

    attr_accessor(*FIELDS)

    validate :no_schools_selected

    def compute_fields
      { site_ids: course.site_ids }.merge(new_attributes)
    end

  private

    def no_schools_selected
      return if params[:site_ids].present?

      if course.recruitment_cycle_rollover_period_2026?
        errors.add(:site_ids, :check_schools) if course.sites.school.present?
        errors.add(:site_ids, :enter_schools) if course.sites.school.blank?
      else
        errors.add(:site_ids, :no_schools)
      end
    end
  end
end
