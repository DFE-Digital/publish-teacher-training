require "rails_helper"

module NotificationService
  describe UnrecognisedEmail do
    let(:email) { "foo@bar.com" }
    let(:service_call) { described_class.call(email: email) }

    before do
      allow(EmailUnrecognisedMailer).to receive(:email_unrecognised).and_return(double(deliver_later: true))
    end

    it "sends a notification" do
      expect(EmailUnrecognisedMailer).to receive(:email_unrecognised).with(email)
      service_call
    end
  end
end
