class WelcomeEmailMailer < GovukNotifyRails::Mailer
  def send_welcome_email(first_name:, email:)
    set_template(Settings.govuk_notify.welcome_email_template_id)

    set_personalisation(
      first_name: first_name,
    )

    mail(to: email)
  end
end
