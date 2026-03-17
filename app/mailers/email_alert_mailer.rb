# frozen_string_literal: true

class EmailAlertMailer < GovukNotifyRails::Mailer
  include ::Courses::ActiveFilters::SummaryRowBuilder

  MAX_USER_INPUT_LENGTH = 200
  COURSE_LIMIT = 20

  def weekly_digest(email_alert, courses)
    set_template(Settings.govuk_notify.email_alert_weekly_digest_template_id)

    @email_alert = email_alert
    @courses = courses.first(COURSE_LIMIT)
    @remaining_count = courses.size - @courses.size
    @subject_names = Subject.where(subject_code: email_alert.subjects).pluck(:subject_name)
    @title = email_subject
    @unsubscribe_url = unsubscribe_url(email_alert)
    @search_url = find_results_url(email_alert.search_params)
    @summary_rows = build_summary_rows(
      email_alert.search_attributes.merge(
        "radius" => email_alert.radius,
        "location" => email_alert.location_name,
      ),
      subject_names: @subject_names,
    ).map { |row| row.merge(value: sanitize_for_notify(row[:value])) }

    set_personalisation(
      subject: @title,
      body: render_to_string("email_alert_mailer/weekly_digest", layout: false),
    )

    mail(to: email_alert.candidate.email_address)
  end

private

  def email_subject
    subject = @subject_names.first if @subject_names.size == 1
    location = sanitize_for_notify(@email_alert.location_name)

    if @courses.size == 1
      provider = @courses.first.provider.provider_name
      one_course_subject(provider:, subject:, location:)
    elsif @courses.size > 1
      many_courses_subject(subject:)
    else
      t("email_alert_mailer.weekly_digest.subject.fallback")
    end
  end

  def one_course_subject(provider:, subject:, location:)
    if subject && location.blank?
      t("email_alert_mailer.weekly_digest.subject.one_course_subject", provider:, subject:)
    elsif subject.nil? && location.blank?
      t("email_alert_mailer.weekly_digest.subject.one_course_no_subject", provider:)
    elsif subject && location.present?
      t("email_alert_mailer.weekly_digest.subject.one_course_subject_location", subject:, location:)
    else
      t("email_alert_mailer.weekly_digest.subject.one_course_location", location:)
    end
  end

  def many_courses_subject(subject:)
    if subject
      t("email_alert_mailer.weekly_digest.subject.many_courses_subject", subject:)
    else
      t("email_alert_mailer.weekly_digest.subject.many_courses", count: @courses.size + @remaining_count)
    end
  end

  def sanitize_for_notify(text)
    return text if text.blank?

    text.gsub(/[\[\]()\n\r#^]/, "").truncate(MAX_USER_INPUT_LENGTH)
  end

  def unsubscribe_url(email_alert)
    find_unsubscribe_email_alert_from_email_url(
      token: email_alert.signed_id(purpose: :unsubscribe, expires_in: 30.days),
    )
  end
end
