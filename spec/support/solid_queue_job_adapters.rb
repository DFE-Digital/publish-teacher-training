# frozen_string_literal: true

# Jobs that set `self.queue_adapter = :solid_queue` ignore ActiveJob::Base's
# :test adapter, so have_enqueued_job / perform_enqueued_jobs would miss them.
# Point them at the shared test adapter for every example, except those tagged
# `solid_queue: true`, which assert real Solid Queue enqueueing.
module SolidQueueJobAdapters
  def self.jobs
    @jobs ||= begin
      Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/jobs"))
      ApplicationJob.descendants.select { |job| job.queue_adapter_name == "solid_queue" }
    end
  end
end

RSpec.configure do |config|
  config.around do |example|
    if example.metadata[:solid_queue]
      example.run
    else
      begin
        SolidQueueJobAdapters.jobs.each { |job| job.enable_test_adapter(ActiveJob::Base.queue_adapter) }
        example.run
      ensure
        SolidQueueJobAdapters.jobs.each(&:disable_test_adapter)
      end
    end
  end
end
