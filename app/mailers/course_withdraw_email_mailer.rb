class CourseWithdrawEmailMailer < GovukNotifyRails::Mailer
  include TimeFormat

  def course_withdraw_email(course, user, datetime)
    set_template(Settings.govuk_notify.course_withdraw_email_template_id)

    set_personalisation(
      provider_name: course.provider.provider_name,
      course_name: course.name,
      course_code: course.course_code,
      withdraw_course_datetime: gov_uk_format(datetime),
      course_url: create_course_url(course),
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
