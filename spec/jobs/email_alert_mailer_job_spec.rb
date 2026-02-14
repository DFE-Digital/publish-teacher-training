# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailAlertMailerJob do
  describe "#perform" do
    let(:candidate) { create(:candidate) }
    let(:alert) { create(:email_alert, candidate:) }
    let(:course) { create(:course, :published) }
    let(:course_ids) { [course.id] }

    it "sends the weekly digest email and updates last_sent_at" do
      mail = double(deliver_now: true)
      allow(EmailAlertMailer).to receive(:weekly_digest).and_return(mail)

      freeze_time do
        described_class.new.perform(alert.id, course_ids)

        expect(EmailAlertMailer).to have_received(:weekly_digest).with(alert, anything)
        expect(mail).to have_received(:deliver_now)
        expect(alert.reload.last_sent_at).to eq(Time.current)
      end
    end

    it "does not send email if the alert has been unsubscribed" do
      alert.unsubscribe!

      allow(EmailAlertMailer).to receive(:weekly_digest)

      described_class.new.perform(alert.id, course_ids)

      expect(EmailAlertMailer).not_to have_received(:weekly_digest)
    end

    it "does not send email if no courses are found" do
      allow(EmailAlertMailer).to receive(:weekly_digest)

      described_class.new.perform(alert.id, [0])

      expect(EmailAlertMailer).not_to have_received(:weekly_digest)
    end

    it "does not update last_sent_at if alert is unsubscribed" do
      alert.unsubscribe!

      described_class.new.perform(alert.id, course_ids)

      expect(alert.reload.last_sent_at).to be_nil
    end
  end
end
