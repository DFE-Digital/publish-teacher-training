module NotificationService
  class CourseUpdated
    include ServicePattern

    def initialize(course:)
      @course = course
    end

    def call
      return unless course_needs_to_notify?

      notifiable_changes.each do |updated_attribute|
        original_value, updated_value = course.saved_changes[updated_attribute]

        users.each do |user|
          CourseUpdateEmailMailer.course_update_email(
            course: course,
            attribute_name: updated_attribute,
            original_value: original_value,
            updated_value: updated_value,
            recipient: user,
          ).deliver_later(queue: "mailer")
        end
      end
    end

  private

    attr_reader :course

    def notifiable_changes
      course.saved_changes.keys & course.update_notification_attributes
    end

    def users
      User.course_update_subscribers(course.accredited_body_code)
    end

    def course_needs_to_notify?
      course.findable? &&
        !course.self_accredited? &&
        notifiable_changes.any? &&
        course.in_current_cycle?
    end
  end
end
