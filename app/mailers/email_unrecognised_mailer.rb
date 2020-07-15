class EmailUnrecognisedMailer < GovukNotifyRails::Mailer
  def email_unrecognised(email)
    set_template(Settings.govuk_notify.email_unrecognised_template_id)

    mail(to: email)
  end
end
