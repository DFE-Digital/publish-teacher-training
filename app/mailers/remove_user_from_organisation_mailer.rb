class RemoveUserFromOrganisationMailer < GovukNotifyRails::Mailer
  def remove_user_from_provider_email(recipient:, provider:)
    set_template(Settings.govuk_notify.remove_user_from_organisation_id)

    set_personalisation(
      provider_name: provider.provider_name,
    )

    mail(to: recipient.email)
  end
end
