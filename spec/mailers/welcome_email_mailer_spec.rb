require "rails_helper"

describe WelcomeEmailMailer, type: :mailer do
  context "Sending an email to a user" do
    let(:mail) { described_class.send_welcome_email(first_name: "meow", email: "cat@meow.cat") }

    before { mail }

    it "Sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.welcome_email_template_id)
    end

    it "Sends an email to the correct email address" do
      expect(mail.to).to eq(["cat@meow.cat"])
    end

    it "Includes the first name in the personalisation" do
      expect(mail.govuk_notify_personalisation).to eq(first_name: "meow")
    end
  end

  context "inputting a nil first name" do
    before do
      allow(Sentry).to receive(:capture_exception).with(WelcomeEmailMailer::MissingFirstNameError).and_return(nil)
    end

    it "raises, captures and sends an error to sentry" do
      expect(Sentry).to receive(:capture_exception).with(WelcomeEmailMailer::MissingFirstNameError)
      described_class.send_welcome_email(first_name: "", email: "cat@meow.cat").deliver_now
    end
  end
end
