# frozen_string_literal: true

module Find
  class ProcessWeeklyEmailAlertsService
    def self.call(since: 1.week.ago, delivery_date: EmailAlertMailerJob.delivery_date_for(Time.current))
      new(since, delivery_date).call
    end

    def initialize(since, delivery_date)
      @since = since
      @delivery_date = delivery_date
    end

    def call
      recently_published_ids = CourseEnrichment
        .joins(course: :provider)
        .merge(Provider.in_current_cycle)
        .where(status: :published)
        .where("last_published_timestamp_utc > ?", @since)
        .select(:course_id)
        .distinct

      BatchDelivery.new(relation: Candidate::EmailAlert.active, stagger_over: 1.hour, batch_size: 100).each do |deliver_at, alerts|
        alerts.each do |alert|
          matching = find_matching_courses(alert, recently_published_ids)
          next if matching.empty?

          EmailAlertMailerJob
            .set(wait_until: deliver_at)
            .perform_later(alert.id, matching.reorder(nil).pluck(:id), @delivery_date)
        end
      end
    end

  private

    def find_matching_courses(alert, recently_published_ids)
      ::Courses::Query.call(params: alert.search_params_for_matching).where(id: recently_published_ids)
    end
  end
end
