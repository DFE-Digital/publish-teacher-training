module CourseVacancies
  class UpdatedMailer < GovukNotifyRails::Mailer
    include TimeFormat

    def fully_updated(course:, user:, datetime:, vacancies_filled:)
      set_template(Settings.govuk_notify.course_vacancies_updated_email_template_id)

      set_personalisation(
        provider_name: course.provider.provider_name,
        course_name: course.name,
        course_code: course.course_code,
        vacancies_updated_datetime: gov_uk_format(datetime),
        course_url: create_course_url(course),
        vacancies_filled: vacancies_filled ? "yes" : "no",
        vacancies_opened: vacancies_filled ? "no" : "yes",
      )

      mail(to: user.email)
    end

    def partially_updated(course:, user:, datetime:, vacancies_opened:, vacancies_closed:)
      set_template(Settings.govuk_notify.course_vacancies_partially_updated_email_template_id)

      set_personalisation(
        provider_name: course.provider.provider_name,
        course_name: course.name,
        course_code: course.course_code,
        vacancies_updated_datetime: gov_uk_format(datetime),
        course_url: create_course_url(course),
        vacancies_opened: vacancies_opened ? vacancies_opened.join(", ") : "none",
        vacancies_closed: vacancies_closed ? vacancies_closed.join(", ") : "none",
      )

      mail(to: user.email)
    end

  private

    def create_course_url(course)
      "#{Settings.find_url}" \
        "/course/#{course.provider.provider_code}" \
        "/#{course.course_code}"
    end
  end
end
