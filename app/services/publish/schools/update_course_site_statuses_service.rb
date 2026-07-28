# frozen_string_literal: true

module Publish
  module Schools
    # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
    # TODO School data remodel removal - remove this legacy SiteStatus sync service when school associations
    # are written only through Provider::School and Course::School.
    # Mirrors submitted Provider::School UUIDs to legacy SiteStatus rows while
    # parts of Publish and the API still read the legacy school model.
    class UpdateCourseSiteStatusesService
      include ServicePattern

      def initialize(course:, school_uuids:)
        @course = course
        @submitted_school_uuids = Array(school_uuids).compact_blank.uniq
      end

      def call
        sync_schools
        apply_publish_status_to_site_statuses
      end

    private

      attr_reader :course, :submitted_school_uuids

      def sync_schools
        return if sites_to_attach_uuids.empty? && sites_to_remove_uuids.empty?

        sites_to_attach_uuids.each { |uuid| attach_school(sites_by_uuid[uuid]) }
        sites_to_remove_uuids.each { |uuid| detach_school(sites_by_uuid[uuid]) }

        course.sites.reload
      end

      def current_site_uuids
        @current_site_uuids ||= course.sites.map(&:uuid)
      end

      # TODO School data remodel removal - remove once course school updates no longer diff legacy Site UUIDs.
      def sites_to_attach_uuids
        @sites_to_attach_uuids ||= submitted_school_uuids - current_site_uuids
      end

      # TODO School data remodel removal - remove once course school updates no longer diff legacy Site UUIDs.
      def sites_to_remove_uuids
        @sites_to_remove_uuids ||= current_site_uuids - submitted_school_uuids
      end

      # TODO School data remodel removal - remove when Provider::School UUIDs no longer need mapping to legacy Sites.
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
          site_status.update!(site_status_attributes)
        end
      end

      def site_status_attributes
        return { publish: :published, status: :running } if course.findable?

        { publish: :unpublished, status: :new_status }
      end
      # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
    end
  end
end
