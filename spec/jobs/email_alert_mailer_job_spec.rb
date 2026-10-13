# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailAlertMailerJob do
  it_behaves_like "a Solid Queue job", queue: "mailers"

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

    it "passes courses to the mailer ordered by newest first" do
      old_course = create(:course, :published,
                          enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 3.days.ago)])
      new_course = create(:course, :published,
                          enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 1.day.ago)])
      mid_course = create(:course, :published,
                          enrichments: [build(:course_enrichment, :published, last_published_timestamp_utc: 2.days.ago)])

      mail = double(deliver_now: true)
      allow(EmailAlertMailer).to receive(:weekly_digest).and_return(mail)

      described_class.new.perform(alert.id, [old_course.id, new_course.id, mid_course.id])

      expect(EmailAlertMailer).to have_received(:weekly_digest) do |_alert, courses|
        expect(courses.map(&:id)).to eq([new_course.id, mid_course.id, old_course.id])
      end
    end

    it "does not send an alert again for the same Friday" do
      allow(EmailAlertMailer).to receive(:weekly_digest)
      friday = Date.new(2026, 10, 16)
      alert.update!(last_sent_at: friday.in_time_zone + 3.hours)

      described_class.new.perform(alert.id, course_ids, friday)

      expect(EmailAlertMailer).not_to have_received(:weekly_digest)
    end

    it "still sends the next Friday's digest after a mid-week catch-up run" do
      allow(EmailAlertMailer).to receive(:weekly_digest).and_return(double(deliver_now: true))
      friday = Date.new(2026, 10, 16)
      alert.update!(last_sent_at: Date.new(2026, 10, 12).in_time_zone + 10.hours)

      described_class.new.perform(alert.id, course_ids, friday)

      expect(EmailAlertMailer).to have_received(:weekly_digest)
    end

    it "uses the enqueue date for a two-argument job queued before this change" do
      allow(EmailAlertMailer).to receive(:weekly_digest)
      job = described_class.new(alert.id, course_ids)
      job.enqueued_at = 2.days.ago
      alert.update!(last_sent_at: 1.day.ago)

      job.perform(alert.id, course_ids)

      expect(EmailAlertMailer).not_to have_received(:weekly_digest)
    end

    it "serializes duplicate copies and sends only once" do
      mail = double(deliver_now: true)
      allow(EmailAlertMailer).to receive(:weekly_digest).and_return(mail)
      allow(Candidate::EmailAlert).to receive(:find).with(alert.id).and_return(alert)
      expect(alert).to receive(:with_lock).twice.and_call_original
      delivery_date = described_class.delivery_date_for(Time.current)

      2.times { described_class.new.perform(alert.id, course_ids, delivery_date) }

      expect(mail).to have_received(:deliver_now).once
    end
  end

  describe ".delivery_date_for" do
    it "uses the day itself on a Friday" do
      expect(described_class.delivery_date_for(Time.zone.local(2026, 10, 16, 3))).to eq(Date.new(2026, 10, 16))
    end

    it "treats a run later in the week as the previous Friday's" do
      expect(described_class.delivery_date_for(Time.zone.local(2026, 10, 12, 10))).to eq(Date.new(2026, 10, 9))
      expect(described_class.delivery_date_for(Time.zone.local(2026, 10, 15, 23))).to eq(Date.new(2026, 10, 9))
    end
  end

  describe "retries" do
    let(:alert) { create(:email_alert) }
    let(:course) { create(:course, :published) }

    def notify_error(klass, code)
      klass.new(instance_double(Net::HTTPResponse, code:, body: "Notify said no"))
    end

    it "does not retry an ambiguous Notify server error" do
      allow(EmailAlertMailer).to receive(:weekly_digest).and_raise(notify_error(Notifications::Client::ServerError, "500"))

      expect {
        described_class.perform_now(alert.id, [course.id])
      }.to raise_error(Notifications::Client::ServerError)
      expect(described_class).not_to have_been_enqueued
    end

    it "does not retry an ambiguous read timeout" do
      allow(EmailAlertMailer).to receive(:weekly_digest).and_raise(Net::ReadTimeout, "timed out")

      expect {
        described_class.perform_now(alert.id, [course.id])
      }.to raise_error(Net::ReadTimeout)
      expect(described_class).not_to have_been_enqueued
    end

    [
      [Net::OpenTimeout, "the connection times out"],
      [SocketError, "DNS lookup fails"],
      [Errno::ECONNREFUSED, "the connection is refused"],
    ].each do |error, description|
      it "tries again when #{description}" do
        allow(EmailAlertMailer).to receive(:weekly_digest).and_raise(error)

        expect { described_class.perform_now(alert.id, [course.id]) }.to have_enqueued_job(described_class)
      end
    end

    it "waits a minute before trying again when Notify rate limits" do
      allow(EmailAlertMailer).to receive(:weekly_digest).and_raise(notify_error(Notifications::Client::RateLimitError, "429"))

      expect { described_class.perform_now(alert.id, [course.id]) }
        .to have_enqueued_job(described_class).at(a_value_between(1.minute.from_now, 75.seconds.from_now))
    end

    it "discards the job when the alert has been deleted" do
      allow(EmailAlertMailer).to receive(:weekly_digest)
      alert_id = alert.id
      alert.destroy!

      expect { described_class.perform_now(alert_id, [course.id]) }.not_to raise_error
      expect(EmailAlertMailer).not_to have_received(:weekly_digest)
      expect(described_class).not_to have_been_enqueued
    end

    it "does not retry when Notify rejects the request" do
      allow(EmailAlertMailer).to receive(:weekly_digest).and_raise(notify_error(Notifications::Client::BadRequestError, "400"))

      expect { described_class.perform_now(alert.id, [course.id]) }.to raise_error(Notifications::Client::BadRequestError)
      expect(described_class).not_to have_been_enqueued
    end

    it "does not retry a deadlock after Notify accepted the email" do
      mail = double(deliver_now: true)
      allow(EmailAlertMailer).to receive(:weekly_digest).and_return(mail)
      allow(Candidate::EmailAlert).to receive(:find).with(alert.id).and_return(alert)
      allow(alert).to receive(:touch).and_raise(ActiveRecord::Deadlocked, "deadlock")

      expect {
        described_class.perform_now(alert.id, [course.id])
      }.to raise_error(ActiveRecord::Deadlocked, "deadlock")
      expect(described_class).not_to have_been_enqueued
      expect(mail).to have_received(:deliver_now).once
    end
  end

  describe "scheduling on Solid Queue", :solid_queue do
    let(:alert) { create(:email_alert) }
    let(:deliver_at) { 30.minutes.from_now.change(usec: 0) }

    it "holds the digest until wait_until, then releases it to the mailers queue" do
      described_class.set(wait_until: deliver_at).perform_later(alert.id, [1])
      job = SolidQueue::Job.find_by!(class_name: described_class.name)

      expect(job.queue_name).to eq("mailers")
      expect(SolidQueue::ScheduledExecution.find_by!(job_id: job.id).scheduled_at).to eq(deliver_at)

      SolidQueue::ScheduledExecution.dispatch_next_batch(10)
      expect(SolidQueue::ReadyExecution.where(job_id: job.id)).to be_empty

      travel_to(deliver_at + 1.second) { SolidQueue::ScheduledExecution.dispatch_next_batch(10) }

      expect(SolidQueue::ScheduledExecution.where(job_id: job.id)).to be_empty
      expect(SolidQueue::ReadyExecution.where(job_id: job.id)).to exist
    end
  end
end
