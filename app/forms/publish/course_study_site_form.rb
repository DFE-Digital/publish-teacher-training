# frozen_string_literal: true

module Publish
  class CourseStudySiteForm < BaseCourseForm
    FIELDS = %i[study_site_ids].freeze

    attr_accessor(*FIELDS)

    def save!
      return false unless valid?
      # Avoid course.save! when the selection is unchanged — that can still
      # refresh "Last updated" via unrelated course update callbacks.
      return true unless study_sites_changed?

      save_action
    end

  private

    def after_successful_save_action
      course.refresh_last_published_at!
      super
    end

    def study_sites_changed?
      normalised_ids(course.study_site_ids) != normalised_ids(study_site_ids)
    end

    def normalised_ids(ids)
      Array(ids).compact_blank.map(&:to_i).sort
    end

    def compute_fields
      { study_site_ids: course.study_site_ids }.merge(new_attributes)
    end
  end
end
