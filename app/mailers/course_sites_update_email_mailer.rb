class CourseSitesUpdateEmailMailer < GovukNotifyRails::Mailer
  include TimeFormat

  def course_sites_update_email(
    course:,
    previous_site_names:,
    updated_site_names:,
    recipient:
  )
    set_template(Settings.govuk_notify.course_sites_update_email_template_id)

    set_personalisation(
      provider_name: course.provider.provider_name,
      course_name: course.name,
      course_code: course.course_code,
      course_url: create_course_url(course),
      previous_site_names: previous_site_names.join(", "),
      updated_site_names: updated_site_names.join(", "),
      sites_updated_datetime: gov_uk_format(course.updated_at),
      )

    mail(to: recipient.email)
  end

private

  def create_course_url(course)
    "#{Settings.find_url}" \
      "/course/#{course.provider.provider_code}" \
      "/#{course.course_code}"
  end
end
