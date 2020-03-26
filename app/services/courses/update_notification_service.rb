module Courses
  class UpdateNotificationService
    def call(course:)
      return unless course_needs_to_notify?(course)

      updated_attribute = notifiable_changes(course).first
      original_value, updated_value = course.saved_changes[updated_attribute]

      users_to_notify(course).each do |user|
        CourseUpdateEmailMailer.course_update_email(
          course: course,
          attribute_name: updated_attribute,
          original_value: original_value,
          updated_value: updated_value,
          recipient: user,
        ).deliver_later(queue: "mailer")
      end
    end

    def notifiable_changes(course)
      (course.saved_changes.keys & course.update_notification_attributes)
    end

    def users_to_notify(course)
      User.notifiable_users(course.provider.provider_code)
    end

    def course_needs_to_notify?(course)
      course.findable? && !course.self_accredited? && notifiable_changes(course).any?
    end
  end
end
