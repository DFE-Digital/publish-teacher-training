module NotificationService
  class CourseUpdated
    include ServicePattern

    def initialize(course:)
      @course = course
    end

    def call
      return unless course_needs_to_notify?

      updated_attribute = notifiable_changes.first
      original_value, updated_value = course.saved_changes[updated_attribute]

      users_to_notify.each do |user|
        CourseUpdateEmailMailer.course_update_email(
          course: course,
          attribute_name: updated_attribute,
          original_value: original_value,
          updated_value: updated_value,
          recipient: user,
        ).deliver_later(queue: "mailer")
      end
    end

  private

    attr_reader :course

    def notifiable_changes
      course.saved_changes.keys & course.update_notification_attributes
    end

    def users_to_notify
      User.joins(:user_notifications).merge(
        UserNotification.course_update_notification_requests(course.accredited_body_code),
      )
    end

    def course_needs_to_notify?
      course.findable? && !course.self_accredited? && notifiable_changes.any?
    end
  end
end
