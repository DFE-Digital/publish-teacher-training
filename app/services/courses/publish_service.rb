# frozen_string_literal: true

module Courses
  class PublishService
    def initialize(course:, user:)
      @course = course
      @user = user
    end

    def call
      Rails.logger.tagged("Course::PublishService") do |l|
        l.info "publishing course uuid: #{course.uuid}"
      end

      return false unless course.publishable?

      publish_course
      send_notification

      course
    end

  private

    attr_reader :user, :course

    def publish_course
      Course.transaction do
        course.undiscard
        publish_sites
        course.publish_enrichment(user)
        course.application_status_open!
      end
    end

    def publish_sites
      course.site_statuses
        .status_new_status
        .update_all(status: SiteStatus.statuses[:running])

      course.site_statuses
        .status_running
        .unpublished_on_ucas
        .update_all(publish: SiteStatus.publishes[:published])
    end

    def send_notification
      NotificationService::CoursePublished.call(course:)
    end
  end
end
