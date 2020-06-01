class CoursePublishEmailMailer < GovukNotifyRails::Mailer
  include TimeFormat

  def course_publish_email(course, user)
    set_template(Settings.govuk_notify.course_create_email_template_id)

    set_personalisation(
      provider_name: course.provider.provider_name,
      course_name: course.name,
      course_code: course.course_code,
      course_description: course.description,
      course_funding_type: course.funding_type,
      create_course_datetime: gov_uk_format(course.created_at),
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
