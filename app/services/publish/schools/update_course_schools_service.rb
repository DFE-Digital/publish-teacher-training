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
        desired_site_ids = Array(params[:site_ids]).compact_blank.map(&:to_i)
        current_site_ids = course.site_ids

        to_attach_ids = desired_site_ids - current_site_ids
        to_detach_ids = current_site_ids - desired_site_ids
        return if to_attach_ids.empty? && to_detach_ids.empty?

        sites_by_id = Site.where(id: to_attach_ids + to_detach_ids).index_by(&:id)
        gias_schools_by_urn = GiasSchool
          .where(urn: sites_by_id.values.map(&:urn).compact_blank)
          .index_by(&:urn)

        to_attach_ids.each { |id| attach_school(sites_by_id[id], gias_schools_by_urn) }
        to_detach_ids.each { |id| detach_school(sites_by_id[id], gias_schools_by_urn) }

        course.sites.reload
      end

      def attach_school(site, gias_schools_by_urn)
        ::CourseSchools::LegacySiteStatusCreator.call(course:, site:)

        gias_school = gias_schools_by_urn[site.urn]
        return unless gias_school

        ::CourseSchools::Creator.call(course:, gias_school_id: gias_school.id)
      end

      def detach_school(site, gias_schools_by_urn)
        ::CourseSchools::LegacySiteStatusRemover.call(course:, site:)

        gias_school = gias_schools_by_urn[site.urn]
        return unless gias_school

        ::CourseSchools::Remover.call(course:, gias_school_id: gias_school.id)
      end

      def apply_publish_status_to_site_statuses
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
