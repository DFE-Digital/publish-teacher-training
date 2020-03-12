class CourseUpdateEmailMailer < GovukNotifyRails::Mailer
  def course_update_email(
    course:,
    attribute_name:,
    original_value:,
    updated_value:,
    recipient:
  )

    set_template(Settings.govuk_notify.course_update_email_template_id)

    set_personalisation(
      provider_name: course.provider.provider_name,
      course_name: course.name,
      course_code: course.course_code,
      attribute_changed: I18n.t("course.update_email.#{attribute_name}"),
      attribute_change_datetime: format_update_datetime(course.updated_at),
      course_url: create_course_url(course),
      original_value: original_value,
      updated_value: updated_value,
    )

    mail(to: recipient.email)
  end

private

  def create_course_url(course)
    "#{Settings.find_url}" \
      "/course/#{course.provider.provider_code}" \
      "/#{course.course_code}"
  end

  def format_update_datetime(datetime)
    datetime.strftime("%-k:%M%P on %-e %B %Y")
  end
end
