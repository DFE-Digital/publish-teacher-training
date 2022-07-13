class UserAddedToProviderMailer < GovukNotifyRails::Mailer
  include TimeFormat

  def user_added_to_provider_email(
    recipient:
  )
    set_template(Settings.govuk_notify.user_added_to_provider_id)

    mail(to: recipient.email)
  end
end
