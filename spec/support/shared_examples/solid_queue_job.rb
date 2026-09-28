# frozen_string_literal: true

# Define `let(:solid_queue_job_args)` when `perform` needs arguments.
shared_examples "a job routed to Solid Queue" do |queue:|
  it "uses Solid Queue explicitly", :solid_queue do
    expect(described_class.queue_adapter).to be_a(ActiveJob::QueueAdapters::SolidQueueAdapter)
  end

  it "enqueues onto the #{queue} queue in Solid Queue", :solid_queue do
    args = respond_to?(:solid_queue_job_args) ? solid_queue_job_args : []
    jobs = SolidQueue::Job.where(class_name: described_class.name)

    expect { described_class.perform_later(*args) }.to change(jobs, :count).by(1)
    expect(jobs.order(:id).last.queue_name).to eq(queue)
  end
end
