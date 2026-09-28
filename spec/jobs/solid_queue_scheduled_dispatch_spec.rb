# frozen_string_literal: true

require "rails_helper"

# Walks a delayed job through the rows the dispatcher and a worker would move
# it between, without running either process.
RSpec.describe "Solid Queue scheduled dispatch", :solid_queue do
  let(:alert) { create(:email_alert) }
  let(:course) { create(:course, :published) }
  let(:worker) do
    SolidQueue::Process.register(kind: "Worker", name: "spec-worker", pid: ::Process.pid, hostname: "spec")
  end

  before do
    allow(EmailAlertMailer).to receive(:weekly_digest).and_return(instance_double(ActionMailer::MessageDelivery, deliver_now: true))
  end

  it "moves a due job from scheduled to ready to finished" do
    freeze_time

    EmailAlertMailerJob.set(wait_until: 10.minutes.from_now).perform_later(alert.id, [course.id])
    job = SolidQueue::Job.find_by!(class_name: "EmailAlertMailerJob")

    expect(job.scheduled_execution).to be_present
    expect(SolidQueue::ScheduledExecution.dispatch_next_batch(10)).to eq(0)

    travel 11.minutes

    expect(SolidQueue::ScheduledExecution.dispatch_next_batch(10)).to eq(1)
    expect(job.reload.scheduled_execution).to be_nil
    expect(job.ready_execution).to be_present

    SolidQueue::ReadyExecution.claim([job.queue_name], 1, worker.id).each(&:perform)

    expect(job.reload).to be_finished
    expect(alert.reload.last_sent_at).to eq(Time.current)
  end
end
