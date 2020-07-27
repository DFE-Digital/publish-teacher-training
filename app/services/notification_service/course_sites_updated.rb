module NotificationService
  class CourseSitesUpdated
    include ServicePattern

    def initialize(course:, previous_site_names:, updated_site_names:)
      @course = course
      @previous_site_names = previous_site_names
      @updated_site_names = updated_site_names
    end

    def call
      return unless course_needs_to_notify?

      users_to_notify.each do |user|
        CourseSitesUpdateEmailMailer.course_sites_update_email(
          course: course,
          previous_site_names: previous_site_names,
          updated_site_names: updated_site_names,
          recipient: user,
          ).deliver_later(queue: "mailer")
      end
    end

  private

    attr_reader :course, :previous_site_names, :updated_site_names

    def users_to_notify
      User.joins(:user_notifications).merge(
        UserNotification.course_update_notification_requests(course.accredited_body_code),
        )
    end

    def course_needs_to_notify?
      course.findable? &&
        !course.self_accredited? &&
        course.in_current_cycle?
    end
  end
end
