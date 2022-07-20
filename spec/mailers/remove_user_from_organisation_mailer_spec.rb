require "rails_helper"

describe RemoveUserFromOrganisationMailer, type: :mailer do
  context "Sending an email to a user" do
    let(:user) { create :user }
    let(:provider) { create :provider }

    let(:mail) { described_class.remove_user_from_provider_email(recipient: user, provider:) }

    before { mail }

    it "Sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.remove_user_from_organisation_id)
    end

    it "Sends an email to the correct email address" do
      expect(mail.to).to eq([user.email])
    end

    it "Includes the provider name in the personalisation" do
      expect(mail.govuk_notify_personalisation).to eq(provider_name: provider.provider_name)
    end
  end
end
