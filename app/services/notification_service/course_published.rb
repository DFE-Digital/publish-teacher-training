module NotificationService
  class CoursePublished
    include ServicePattern

    def initialize(course:)
      @course = course
    end

    def call
      return false unless notify_accredited_body?

      users = User.joins(:user_notifications).merge(UserNotification.course_publish_notification_requests(course.accrediting_provider_code))

      users.each do |user|
        CoursePublishEmailMailer.course_publish_email(
          course,
          user,
        ).deliver_later(queue: "mailer")
      end
    end

  private

    attr_reader :course

    def notify_accredited_body?
      return false if course.self_accredited?
      return false unless course.findable?

      true
    end
  end
end
