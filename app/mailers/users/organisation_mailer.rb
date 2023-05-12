# frozen_string_literal: true

module Users
  class OrganisationMailer < GovukNotifyRails::Mailer
    def added_as_an_organisation_to_training_partner(recipient:, provider:, accredited_provider:)
      set_template(Settings.govuk_notify.user_added_as_organisation_to_training_partner_id)

      set_personalisation(
        email_address: recipient.email,
        provider_name: provider.provider_name,
        accredited_provider_name: accredited_provider.provider_name
      )

      mail(to: recipient.email)
    end
  end
end
