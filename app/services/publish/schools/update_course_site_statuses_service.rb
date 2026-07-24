module Publish
  module Schools
    # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
    # TODO School data remodel removal - remove this legacy SiteStatus sync service when school associations
    # are written only through Provider::School and Course::School.
    class UpdateCourseSiteStatusesService
      include ServicePattern

      def initialize(course:, params:, send_notifications: true)
        @course = course
        @params = params.to_h.deep_symbolize_keys
        raise ArgumentError, "school_uuids must be provided" unless @params.key?(:school_uuids)

        @previous_site_names = course.sites.map(&:location_name)
        @send_notifications = send_notifications
      end

      def call
        ActiveRecord::Base.transaction do
          assign_attributes_to_course
          sync_schools
          apply_publish_status_to_site_statuses
          course.save!
        end

        send_notifications if send_notifications?
      end

    private

      attr_reader :course, :params, :previous_site_names

      def send_notifications?
        @send_notifications
      end

      def assign_attributes_to_course
        course.assign_attributes(params.except(:school_uuids))
      end

      def sync_schools
        return if sites_to_attach_uuids.empty? && sites_to_remove_uuids.empty?

        sites_to_attach_uuids.each { |uuid| attach_school(sites_by_uuid[uuid]) }
        sites_to_remove_uuids.each { |uuid| detach_school(sites_by_uuid[uuid]) }

        course.sites.reload
      end

      def submitted_school_uuids
        @submitted_school_uuids ||= Array(params[:school_uuids]).compact_blank.uniq
      end

      def current_school_uuids
        @current_school_uuids ||= course.sites.map(&:uuid)
      end

      # TODO School data remodel removal - remove once course school updates no longer diff legacy Site UUIDs.
      def sites_to_attach_uuids
        @sites_to_attach_uuids ||= submitted_school_uuids - current_school_uuids
      end

      # TODO School data remodel removal - remove once course school updates no longer diff legacy Site UUIDs.
      def sites_to_remove_uuids
        @sites_to_remove_uuids ||= current_school_uuids - submitted_school_uuids
      end

      # TODO School data remodel removal - remove once submitted school UUIDs point directly at Provider::School.
      def sites_by_uuid
        @sites_by_uuid ||= course.provider.sites
          .where(uuid: sites_to_attach_uuids + sites_to_remove_uuids)
          .index_by(&:uuid)
      end

      # TODO School data remodel removal - remove with the legacy SiteStatus write path.
      def attach_school(site)
        return if site.blank?

        ::CourseSchools::LegacySiteStatusCreator.call(course:, site:)
      end

      # TODO School data remodel removal - remove with the legacy SiteStatus write path.
      def detach_school(site)
        return if site.blank?

        ::CourseSchools::LegacySiteStatusRemover.call(course:, site:)
      end

      # TODO School data remodel removal - remove when publish status no longer has to be mirrored to SiteStatus.
      def apply_publish_status_to_site_statuses
        # Reload + scope to new_or_running so we never touch site_statuses
        # that sync_schools just suspended or destroyed. Iterating the
        # cached collection used to flip a freshly-suspended row back to
        # running, leaving the unticked school still attached on the
        # rendered page.
        course.site_statuses.reload.new_or_running.each do |site_status|
          site_status.assign_attributes(site_status_attributes)
        end
      end

      def site_status_attributes
        return { publish: :published, status: :running } if course.findable?

        { publish: :unpublished, status: :new_status }
      end
      # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

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
