class CourseVacanciesUpdatedEmailMailer < GovukNotifyRails::Mailer
  include TimeFormat

  def course_vacancies_updated_email(course:, user:, datetime:, vacancies_filled:)
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

private

  def create_course_url(course)
    "#{Settings.find_url}" \
      "/course/#{course.provider.provider_code}" \
      "/#{course.course_code}"
  end
end
