# frozen_string_literal: true

module Support
  module Courses
    class RevertWithdrawalService
      def initialize(course)
        @course = course
      end

      def call
        return unless @course.is_withdrawn?

        update_enrichments
        update_site_status
        close_course
      end

      private

      def update_enrichments
        @course.enrichments.max_by(&:created_at).update(status: 'published', last_published_timestamp_utc: Time.now.utc)
      end

      def update_site_status
        @course.site_statuses.each do |site_status|
          site_status.update(status: :running)
        end
      end

      def close_course
        @course.update(application_status: 'closed')
      end
    end
  end
end
