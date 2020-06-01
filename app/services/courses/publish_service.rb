module Courses
  class PublishService
    class << self
      def call(course:)
        new.call(course: course)
      end
    end

    def call(course:)
      return false unless notify_accredited_body?(course)

      users = User.joins(:user_notifications).merge(UserNotification.course_publish_notification_requests(course.accrediting_provider_code))
      users.each do |user|
        CoursePublishEmailMailer.course_publish_email(
          course,
          user,
        ).deliver_later(queue: "mailer")
      end
    end

  private

    def notify_accredited_body?(course)
      return false if course.self_accredited?
      return false unless course.findable?

      true
    end
  end
end
