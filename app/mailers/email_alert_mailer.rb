# frozen_string_literal: true

class EmailAlertMailer < GovukNotifyRails::Mailer
  def weekly_digest(email_alert, courses)
    set_template(Settings.govuk_notify.email_alert_weekly_digest_template_id)

    set_personalisation(
      title: email_alert_title(email_alert),
      course_count: courses.size.to_s,
      course_list: format_course_list(courses),
      unsubscribe_url: unsubscribe_url(email_alert),
    )

    mail(to: email_alert.candidate.email_address)
  end

private

  def email_alert_title(email_alert)
    subject_names = Subject.where(subject_code: email_alert.subjects).pluck(:subject_name)
    location = email_alert.location_name
    radius = email_alert.radius

    if subject_names.size == 1 && location.blank?
      "#{subject_names.first} courses in England"
    elsif subject_names.size == 2 && location.blank?
      "#{subject_names.first} and #{subject_names.second} courses in England"
    elsif subject_names.size >= 3 && location.blank?
      "#{subject_names.size} subjects in England"
    elsif location.present? && subject_names.size <= 2 && subject_names.any?
      "#{subject_names.join(' and ')} courses within #{radius} miles of #{location}"
    elsif location.present?
      "Courses within #{radius} miles of #{location}"
    else
      "your saved search"
    end
  end

  def format_course_list(courses)
    courses.first(20).map { |course|
      "#{course.name} - #{course.provider.provider_name} (#{course.course_code})"
    }.join("\n")
  end

  def unsubscribe_url(email_alert)
    find_unsubscribe_email_alert_from_email_url(
      token: email_alert.signed_id(purpose: :unsubscribe, expires_in: 30.days),
    )
  end
end
