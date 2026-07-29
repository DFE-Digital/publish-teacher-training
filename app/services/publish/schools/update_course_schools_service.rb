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
          sync_schools
          apply_publish_status_to_site_statuses
          course.save!
        end

        send_notifications
      end

    private

      attr_reader :course, :params, :previous_site_names

      def assign_attributes_to_course
        course.assign_attributes(params.except(:site_ids))
      end

      def sync_schools
        return if sites_to_attach_ids.empty? && sites_to_remove_ids.empty?

        sites_to_attach_ids.each { |id| attach_school(sites_by_id[id]) }
        sites_to_remove_ids.each { |id| detach_school(sites_by_id[id]) }

        course.sites.reload
      end

      def submitted_site_ids
        @submitted_site_ids ||= Array(params[:site_ids]).compact_blank.map(&:to_i)
      end

      def current_site_ids
        @current_site_ids ||= course.site_ids
      end

      def sites_to_attach_ids
        @sites_to_attach_ids ||= submitted_site_ids - current_site_ids
      end

      def sites_to_remove_ids
        @sites_to_remove_ids ||= current_site_ids - submitted_site_ids
      end

      def sites_by_id
        @sites_by_id ||= Site.where(id: sites_to_attach_ids + sites_to_remove_ids).index_by(&:id)
      end

      def gias_schools_by_urn
        @gias_schools_by_urn ||= GiasSchool
          .where(urn: sites_by_id.values.map(&:urn).compact_blank)
          .index_by(&:urn)
      end

      def provider_schools_by_gias_id
        @provider_schools_by_gias_id ||= course.provider.schools
          .where(gias_school_id: gias_schools_by_urn.values.map(&:id))
          .index_by(&:gias_school_id)
      end

      # site → urn → gias_school → provider_school. The uuid reverse map
      # replaces this hop when the pickers move to Provider::School.
      def provider_school_for(site)
        gias_school = gias_schools_by_urn[site.urn]
        return if gias_school.nil?

        provider_school = provider_schools_by_gias_id[gias_school.id]

        if provider_school.nil?
          # Environment hasn't been fully backfilled or the provider's site
          # predates the dual-write. Skip the new-model write rather than
          # 404'ing the request; the schools backfill (or the next
          # provider-side dual-write) reconciles later.
          Rails.logger.warn(
            "[CourseSchools] skipped course_school write — no provider_school for " \
            "course=#{course.id} provider=#{course.provider_id} gias_school=#{gias_school.id}",
          )
        end

        provider_school
      end

      def attach_school(site)
        ::CourseSchools::LegacySiteStatusCreator.call(course:, site:)

        provider_school = provider_school_for(site)
        return unless provider_school

        ::CourseSchools::Creator.call(course:, provider_school:)
      end

      def detach_school(site)
        ::CourseSchools::LegacySiteStatusRemover.call(course:, site:)

        provider_school = provider_school_for(site)
        return unless provider_school

        ::CourseSchools::Remover.call(course:, provider_school:)
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
