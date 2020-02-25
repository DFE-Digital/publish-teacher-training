class CourseUpdateEmailMailer < GovukNotifyRails::Mailer
  def course_update_email(course, attribute_changed, user)
    set_template(Settings.govuk_notify.course_update_email_template_id)

    set_personalisation(
      provider_name: course.provider.provider_name,
      course_name: course.name,
      course_code: course.course_code,
      attribute_changed: attribute_changed,
      attribute_change_datetime: format_update_datetime(course.updated_at),
      course_url: create_course_url(course),
    )

    mail(to: user.email)
  end

private

  def create_course_url(course)
    "#{Settings.publish_url}" \
      "/organisations/#{course.provider.provider_code}" \
      "/#{course.provider.recruitment_cycle.year}" \
      "/courses/#{course.course_code}"
  end

  def format_update_datetime(datetime)
    datetime.strftime("%-k.%M on %-e %B %Y")
  end
end
