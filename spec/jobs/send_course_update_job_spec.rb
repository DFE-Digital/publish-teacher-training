require "rails_helper"

describe SendCourseUpdateJob, type: :job do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  let(:course) { "course" }
  let(:attribute_name) { "attribute_name" }
  let(:original_value) { "original_value" }
  let(:updated_value) { "updated_value" }
  let(:recipient) { "recipient" }

  describe "#perform" do
    it "calls the CourseUpdateEmailMailer" do
      allow(CourseUpdateEmailMailer).to receive_message_chain(:course_update_email, :deliver_now)

      described_class.new.perform(
        course: course,
        attribute_name: attribute_name,
        original_value: original_value,
        updated_value: updated_value,
        recipient: recipient
      )

      expect(CourseUpdateEmailMailer).to have_received(:course_update_email).with(
        course: course,
        attribute_name: attribute_name,
        original_value: original_value,
        updated_value: updated_value,
        recipient: recipient
      )
    end
  end

  describe ".perform_later" do
    it "adds the job to the queue :mailer" do
      allow(CourseUpdateEmailMailer).to receive_message_chain(:course_update_email, :deliver_now)

      described_class.perform_later(
        course: course,
        attribute_name: attribute_name,
        original_value: original_value,
        updated_value: updated_value,
        recipient: recipient
      )

      expect(enqueued_jobs.last[:job]).to eq described_class
      expect(enqueued_jobs.last[:queue]).to eq "mailer"
    end
  end
end
