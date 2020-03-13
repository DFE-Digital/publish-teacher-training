module Courses
  class PublishCourseService
    def execute(course:)
      return false unless notify_accredited_body?(course)

      users = User.joins(:user_notifications).merge(UserNotification.course_create_notification_requests(course.accrediting_provider_code))
      users.each do |user|
        CourseCreateEmailMailer.course_create_email(
          course,
          user,
        ).deliver_now
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
