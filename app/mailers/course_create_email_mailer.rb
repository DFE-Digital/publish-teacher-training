class CourseCreateEmailMailer < GovukNotifyRails::Mailer
  def course_create_email(course, user)
    set_template(Settings.govuk_notify.course_create_email_template_id)

    set_personalisation(
      provider_name: course.provider.provider_name,
      course_name: course.name,
      course_code: course.course_code,
      create_course_datetime: format_create_datetime(course.created_at),
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

  def format_create_datetime(datetime)
    datetime.strftime("%-k:%M%P on %-e %B %Y")
  end
end
