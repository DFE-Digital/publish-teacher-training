module Publish
  module Schools
    class UpdateCourseSchoolsService
      ENQUEUE_THRESHOLD = 30

      def self.call_or_enqueue(course:, params:)
        site_ids_count = Array(params[:site_ids]).size

        if site_ids_count > ENQUEUE_THRESHOLD
          UpdateCourseSchoolsJob.perform_async(course.id, params.to_h)
        else
          new(course:, params:).call
        end
      end

      def initialize(course:, params:)
        @course = course
        @params = { site_ids: course.site_ids }.merge(params.to_h.deep_symbolize_keys)
        @previous_site_names = course.sites.map(&:location_name)
      end

      def call
        ActiveRecord::Base.transaction do
          assign_attributes_to_course
          update_site_statuses
          course.save!
        end

        send_notifications
      end

    private

      attr_reader :course, :params, :previous_site_names

      def assign_attributes_to_course
        course.assign_attributes(params.except(:site_ids))
      end

      def update_site_statuses
        course.site_ids = params[:site_ids]

        course.site_statuses.each do |site_status|
          site_status.assign_attributes(site_status_attributes)
        end
      end

      def site_status_attributes
        return { publish: :published, status: :running } if course.findable?

        { publish: :unpublished, status: :new_status }
      end

      def send_notifications
        updated_site_names = course.sites.map(&:location_name)
        return if previous_site_names == updated_site_names

        if FeatureFlag.active?(:course_sites_updated_email_notification)
          NotificationService::CourseSitesUpdated.call(
            course: course,
            previous_site_names: previous_site_names,
            updated_site_names: updated_site_names,
          )
        end
      end
    end
  end
end
