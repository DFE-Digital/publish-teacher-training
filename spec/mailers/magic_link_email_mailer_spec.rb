require "rails_helper"

describe MagicLinkEmailMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:mail) { described_class.magic_link_email(user) }

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
      expect(mail.to).to eq([user.email])
    end

    it "includes the first name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:first_name]).to(
        eq(user.first_name),
      )
    end

    it "includes the magic link url in the personalisation" do
      expect(mail.govuk_notify_personalisation[:magic_link_url]).to(
        eq(
          "#{Settings.publish_url}/signin_with_magic_link" \
          "?email=#{user.email}" \
          "&token=#{user.magic_link_token}",
        ),
      )
    end
  end
end
