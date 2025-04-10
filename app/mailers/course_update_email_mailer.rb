# frozen_string_literal: true

class CourseUpdateEmailMailer < GovukNotifyRails::Mailer
  include TimeFormat

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
      course_name: set_course_name(course, attribute_name, original_value),
      course_code: course.course_code,
      course_description: course.description,
      course_funding_type: course.funding,
      attribute_changed: I18n.t("course.update_email.#{attribute_name}"),
      attribute_change_datetime: gov_uk_format(course.updated_at),
      course_url: create_course_url(course),
      original_value: formatter.call(name: attribute_name, value: original_value),
      updated_value: formatter.call(name: attribute_name, value: updated_value),
    )

    mail(to: recipient.email)
  end

private

  def create_course_url(course)
    "#{Settings.find_url}" \
      "/course/#{course.provider.provider_code}" \
      "/#{course.course_code}"
  end

  def formatter
    CourseAttributeFormatterService
  end

  def set_course_name(course, attribute_name, original)
    return original if attribute_name == "name"

    course.name
  end
end
