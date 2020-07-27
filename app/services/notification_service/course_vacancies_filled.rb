module NotificationService
  class CourseVacanciesFilled
    include ServicePattern

    def initialize(course:)
      @course = course
    end

    def call
      return false unless notify_accredited_body?

      # Reusing existing scoping as we're doing all or nothing notifications atm
      # for course_publish_notification_requests
      users.each do |user|
        CourseVacanciesFilledEmailMailer.course_vacancies_filled_email(
          course,
          user,
          DateTime.now,
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
      return false unless course.in_current_cycle?

      true
    end
  end
end
