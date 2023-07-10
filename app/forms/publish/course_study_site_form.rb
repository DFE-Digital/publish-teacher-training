# frozen_string_literal: true

module Publish
  class CourseStudySiteForm < BaseCourseForm
    FIELDS = %i[study_site_ids].freeze

    attr_accessor(*FIELDS)

    validates :study_site_ids, presence: true

    private

    def compute_fields
      { study_site_ids: course.study_site_ids }.merge(new_attributes)
    end
  end
end
