require "rails_helper"

describe EmailUnrecognisedMailer, type: :mailer do
  let(:email) { "foo@bar.com" }
  let(:mail) { described_class.email_unrecognised(email) }

  before do
    mail
  end

  context "sending an email to a user" do
    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to(
        eq(Settings.govuk_notify.magic_link_email_template_id),
        )
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([email])
    end
  end
end
