module NotificationService
  class CoursePublished
    include ServicePattern

    def initialize(course:)
      @course = course
    end

    def call
      return false unless notify_accredited_body?
      return false unless course.in_current_cycle?

      users.each do |user|
        CoursePublishEmailMailer.course_publish_email(
          course,
          user,
        ).deliver_later(queue: "mailer")
      end
    end

  private

    attr_reader :course

    def users
      User.course_publish_subscribers(course.accredited_body_code)
    end

    def notify_accredited_body?
      return false if course.self_accredited?
      return false unless course.findable?

      true
    end
  end
end
