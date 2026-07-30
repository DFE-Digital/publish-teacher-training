module Publish
  module Schools
    class UpdateCourseSchoolsService
      ENQUEUE_THRESHOLD = 30

      # A Provider::School the picker offered but whose legacy Site has gone.
      # Course.findable joins site_statuses, so attaching one without its
      # SiteStatus would publish a course no location search can return.
      MissingLegacySite = Class.new(StandardError)

      def self.call_or_enqueue(course:, params:)
        params = normalise_params(course:, params:)

        if Array(params[:school_uuids]).compact_blank.size > ENQUEUE_THRESHOLD
          UpdateCourseSchoolsJob.perform_async(course.id, params.to_h)
        else
          new(course:, params:).call
        end
      end

      # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
      # TODO School data remodel removal - delete once no caller sends site_ids
      # and no job enqueued by the previous release is still in the queue.
      #
      # Translates a legacy site_ids payload into school_uuids. Two senders
      # need it: jobs enqueued before this deploy (by definition the largest
      # submissions, since only those above ENQUEUE_THRESHOLD are enqueued),
      # and the pickers until they post uuids themselves. Without it the
      # service would see no school_uuids, diff against nothing and silently
      # discard the update.
      def self.normalise_params(course:, params:)
        # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
        params = params.to_h.deep_symbolize_keys
        return params.except(:site_ids) if params.key?(:school_uuids)
        return params unless params.key?(:site_ids)

        site_uuids = course.provider.sites.where(id: Array(params[:site_ids]).compact_blank).pluck(:uuid)
        school_uuids = course.provider.schools.where(uuid: site_uuids).pluck(:uuid)

        params.except(:site_ids).merge(school_uuids: school_uuids.map(&:to_s))
      end

      def initialize(course:, params:)
        @course = course
        @params = self.class.normalise_params(course:, params:)
        @previous_school_names = attached_school_names
      end

      def call
        ActiveRecord::Base.transaction do
          assign_attributes_to_course
          sync_schools
          apply_publish_status_to_site_statuses
          course.save!
        end

        send_notifications
      end

    private

      attr_reader :course, :params, :previous_school_names

      def identity
        @identity ||= ::CourseSchools::Identity.new(provider: course.provider, course:)
      end

      def assign_attributes_to_course
        course.assign_attributes(params.except(:school_uuids))
      end

      def sync_schools
        return if uuids_to_attach.empty? && uuids_to_remove.empty?

        uuids_to_attach.each { |uuid| attach_school(uuid) }
        uuids_to_remove.each { |uuid| detach_school(uuid) }

        course.schools.reload
        course.sites.reload
      end

      # An absent key means "leave the schools alone" — the same submission
      # can carry only other course attributes.
      def submitted_uuids
        @submitted_uuids ||= Array(params.fetch(:school_uuids, current_uuids)).compact_blank.map(&:to_s).uniq
      end

      # Only schools the picker could render. An attachment it cannot
      # represent is in neither set, so it is never treated as a removal.
      def current_uuids
        @current_uuids ||= identity.current_school_uuids
      end

      def uuids_to_attach
        @uuids_to_attach ||= submitted_uuids - current_uuids
      end

      def uuids_to_remove
        @uuids_to_remove ||= current_uuids - submitted_uuids
      end

      def provider_schools_by_uuid
        @provider_schools_by_uuid ||= course.provider.schools
          .includes(:gias_school, :legacy_site)
          .where(uuid: uuids_to_attach + uuids_to_remove)
          .index_by { |provider_school| provider_school.uuid.to_s }
      end

      def attach_school(uuid)
        provider_school = provider_schools_by_uuid[uuid]
        return if provider_school.nil?

        attach_legacy_site_status(provider_school)
        ::CourseSchools::Creator.call(course:, provider_school:)
      end

      def detach_school(uuid)
        provider_school = provider_schools_by_uuid[uuid]
        return if provider_school.nil?

        detach_legacy_site_status(provider_school)
        ::CourseSchools::Remover.call(course:, provider_school:)
      end

      def attach_legacy_site_status(provider_school)
        return unless identity.legacy_site_writes?

        site = provider_school.legacy_site

        if site.nil?
          raise MissingLegacySite,
                "no kept site for provider_school=#{provider_school.id} " \
                "uuid=#{provider_school.uuid} course=#{course.id}"
        end

        ::CourseSchools::LegacySiteStatusCreator.call(course:, site:)
      end

      # Detaching is the user cleaning up, so a missing site must not block
      # them. It leaves any site_status pointing at a discarded site behind,
      # which is a pre-existing data problem the pre-flight report counts.
      def detach_legacy_site_status(provider_school)
        return unless identity.legacy_site_writes?

        site = provider_school.legacy_site

        if site.nil?
          Rails.logger.warn(
            "[CourseSchools] detached course_school with no kept site — " \
            "provider_school=#{provider_school.id} course=#{course.id}",
          )
          return
        end

        ::CourseSchools::LegacySiteStatusRemover.call(course:, site:)
      end

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

      # Built from a fresh identity each time: the memoised one is a snapshot,
      # and this is called either side of the update. Sorted because neither
      # course.schools nor the legacy union has an inherent order, and an
      # unstable order would send a notification for an unchanged course.
      def attached_school_names
        identity = ::CourseSchools::Identity.new(provider: course.provider, course:)

        identity.school_records_for(school_uuids: identity.current_school_uuids)
                .records
                .map(&:location_name)
                .sort
      end

      def send_notifications
        updated_school_names = attached_school_names
        return if previous_school_names == updated_school_names
        return unless FeatureFlag.active?(:course_sites_updated_email_notification)

        NotificationService::CourseSitesUpdated.call(
          course: course,
          previous_site_names: previous_school_names,
          updated_site_names: updated_school_names,
        )
      end
    end
  end
end
