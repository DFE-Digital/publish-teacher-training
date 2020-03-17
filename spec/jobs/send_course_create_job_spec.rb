require "rails_helper"

describe SendCourseCreateJob, type: :job do
  include ActiveJob::TestHelper

  let(:course) { create(:course) }
  let(:user) { create(:user) }

  before do
    clear_enqueued_jobs
  end

  describe "#perform" do
    it "calls the CourseCreateEmailMailer" do
      allow(CourseCreateEmailMailer)
        .to receive_message_chain(:course_create_email, :deliver_now)

      described_class.new.perform(course: course, user: user)

      expect(CourseCreateEmailMailer)
        .to have_received(:course_create_email)
        .with(course, user)
    end
  end

  describe ".perform_later" do
    it "adds the job to the queue :mailer" do
      allow(CourseCreateEmailMailer)
        .to receive_message_chain(:course_create_email, :deliver_now)

      described_class.perform_later(course: course, user: user)

      expect(enqueued_jobs.last[:job]).to eq described_class
      expect(enqueued_jobs.last[:queue]).to eq "mailer"
    end
  end
end
