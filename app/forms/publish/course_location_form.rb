module Publish
  class CourseLocationForm < BaseModelForm
    alias_method :course, :model

    FIELDS = %i[site_ids].freeze

    attr_accessor(*FIELDS)

    validate :no_locations_selected

  private

    def compute_fields
      { site_ids: course.site_ids }.merge(new_attributes)
    end

    def no_locations_selected
      return unless site_ids.nil?

      errors.add(:site_ids, :no_locations)
    end
  end
end
