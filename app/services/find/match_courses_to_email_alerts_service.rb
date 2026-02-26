# frozen_string_literal: true

module Find
  class MatchCoursesToEmailAlertsService
    def self.call(since: 1.week.ago)
      new(since).call
    end

    def initialize(since)
      @since = since
    end

    def call
      recently_published_ids = CourseEnrichment
        .joins(course: :provider)
        .merge(Provider.in_current_cycle)
        .where(status: :published)
        .where("last_published_timestamp_utc > ?", @since)
        .select(:course_id)

      BatchDelivery.new(relation: EmailAlert.active, stagger_over: 1.hour, batch_size: 100).each do |deliver_at, alerts|
        alerts.each do |alert|
          matching = find_matching_courses(alert, recently_published_ids)
          next if matching.empty?

          EmailAlertMailerJob.set(wait_until: deliver_at).perform_later(alert.id, matching.reorder(nil).pluck(:id))
        end
      end
    end

  private

    def find_matching_courses(alert, recently_published_ids)
      ::Courses::Query.call(params: alert.search_params.dup).where(id: recently_published_ids)
    end
  end
end
