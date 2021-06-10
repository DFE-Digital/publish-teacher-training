module NotificationService
  class CourseVacanciesUpdated
    include ServicePattern

    def initialize(course:, vacancy_statuses:)
      @course = course
      @vacancy_statuses = vacancy_statuses
    end

    def call
      return false unless notify_accredited_body?

      if all_vacancies_closed?
        send_course_vacancies_updated_notification(vacancies_filled: true)
      elsif all_vacancies_open?
        send_course_vacancies_updated_notification(vacancies_filled: false)
      else
        send_course_vacancies_partially_updated_notification
      end
    end

  private

    attr_reader :course, :vacancy_statuses

    def send_course_vacancies_updated_notification(vacancies_filled:)
      users.each do |user|
        CourseVacancies::UpdatedMailer.fully_updated(
          course: course,
          user: user,
          datetime: Time.zone.now,
          vacancies_filled: vacancies_filled,
        ).deliver_later
      end
    end

    def send_course_vacancies_partially_updated_notification
      users.each do |user|
        CourseVacancies::UpdatedMailer.partially_updated(
          course: course,
          user: user,
          datetime: Time.zone.now,
          vacancies_opened: vacancies_opened,
          vacancies_closed: vacancies_closed,
        ).deliver_later
      end
    end

    def all_vacancies_open?
      vacancy_statuses.all? do |vacancy_status|
        vacancy_status[:status] == "full_time_vacancies" ||
          vacancy_status[:status] == "both_full_time_and_part_time_vacancies" ||
          vacancy_status[:status] == "part_time_vacancies"
      end
    end

    def all_vacancies_closed?
      vacancy_statuses.all? { |vacancy_status| vacancy_status[:status] == "no_vacancies" }
    end

    def vacancies_closed
      vacancy_statuses
        .select { |vacancy_status| vacancy_status[:status] == "no_vacancies" }
        .map { |vacancy_status| SiteStatus.find(vacancy_status[:id]).site.location_name }
    end

    def vacancies_opened
      vacancy_statuses
        .select { |vacancy_status| vacancy_status[:status] == "full_time_vacancies" || vacancy_status[:status] == "part_time_vacancies" || vacancy_status[:status] == "both_full_time_and_part_time_vacancies" }
        .map { |vacancy_status| SiteStatus.find(vacancy_status[:id]).site.location_name }
    end

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
