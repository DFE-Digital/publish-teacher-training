class WelcomeEmailMailer < GovukNotifyRails::Mailer
  class MissingFirstNameError < StandardError; end

  def send_welcome_email(first_name:, email:)
    # Getting visibility on the missing personalisation first_name issue
    raise MissingFirstNameError, "You must provide a firstname personalisation." if first_name.blank?

    set_template(Settings.govuk_notify.welcome_email_template_id)

    set_personalisation(
      first_name:,
    )

    mail(to: email)
  rescue MissingFirstNameError => e
    Sentry.capture_exception(e)
  end
end
