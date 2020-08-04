module NotificationService
  class CourseVacanciesUpdated
    include ServicePattern

    def initialize(course:, vacancies_filled:)
      @course = course
      @vacancies_filled = vacancies_filled
    end

    def call
      return false unless notify_accredited_body?

      # Reusing existing scoping as we're doing all or nothing notifications atm
      # for course_publish_notification_requests
      users.each do |user|
        CourseVacanciesUpdatedEmailMailer.course_vacancies_updated_email(
          course: course,
          user: user,
          datetime: DateTime.now,
          vacancies_filled: vacancies_filled,
        ).deliver_later(queue: "mailer")
      end
    end

  private

    attr_reader :course, :vacancies_filled

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
