# frozen_string_literal: true

module Publish
  class CourseSchoolForm < BaseCourseForm
    FIELDS = %i[site_ids].freeze

    attr_accessor(*FIELDS)

    validate :no_schools_selected

    def initialize(model, params: {})
      @previous_site_names = model.sites.map(&:location_name)
      super
    end

    # def assign_attributes_to_model
    #  model.assign_attributes(fields.except(*fields_to_ignore_before_save))
    # end

    def save_action
      model.transaction do
        assign_attributes_to_model
        #        update_site_statuses
        #        after_successful_save_action
        #        true
      end
    end

  private

    attr_reader :previous_site_names

    def after_successful_save_action
      return if previous_site_names == updated_site_names

      NotificationService::CourseSitesUpdated.call(
        course:,
        previous_site_names:,
        updated_site_names:,
      )
    end

    def updated_site_names
      @updated_site_names ||= course.sites.map(&:location_name)
    end

    def update_site_statuses
      course.site_statuses.each do |site_status|
        site_status.update!(site_status_attributes)
      end
    end

    def compute_fields
      { site_ids: course.site_ids }.merge(new_attributes)
    end

    def no_schools_selected
      return if params[:site_ids].present?

      errors.add(:site_ids, :no_schools)
    end

    def site_status_attributes
      return { publish: :published, status: :running } if course.findable?

      { publish: :unpublished, status: :new_status }
    end
  end
end
