module Publish
  class CourseLocationForm < BaseCourseForm
    FIELDS = %i[site_ids].freeze

    attr_accessor(*FIELDS)

    validate :no_locations_selected

    def initialize(model, params: {})
      @previous_site_names = model.sites.map(&:location_name)
      super
    end

  private

    attr_reader :previous_site_names

    def after_successful_save_action
      return if previous_site_names == updated_site_names

      NotificationService::CourseSitesUpdated.call(
        course: course,
        previous_site_names: previous_site_names,
        updated_site_names: updated_site_names,
      )
    end

    def updated_site_names
      @updated_site_names ||= course.sites.map(&:location_name)
    end

    def compute_fields
      { site_ids: course.site_ids }.merge(new_attributes)
    end

    def no_locations_selected
      return if params[:site_ids].present?

      errors.add(:site_ids, :no_locations)
    end
  end
end
