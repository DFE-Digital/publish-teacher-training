require "rails_helper"

describe SendWelcomeJob, type: :job do
  include ActiveJob::TestHelper

  let(:current_user) { { first_name: "Whiskers", email: "whiskers@meow.com" } }

  before do
    clear_enqueued_jobs
  end

  describe "#perform" do
    it "calls the WelcomeEmailMailer" do
      allow(SendWelcomeEmailService).to receive(:call)

      described_class.new.perform(current_user: current_user)

      expect(SendWelcomeEmailService).to have_received(:call)
    end
  end

  describe ".perform_later" do
    it "adds the job to the queue :mailer" do
      allow(SendWelcomeEmailService).to receive(:call)

      described_class.perform_later(current_user: current_user)

      expect(enqueued_jobs.last[:job]).to eq described_class
      expect(enqueued_jobs.last[:queue]).to eq "mailer"
    end
  end
end
