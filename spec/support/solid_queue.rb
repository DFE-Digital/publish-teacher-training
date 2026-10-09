# frozen_string_literal: true

# Jobs that set `self.queue_adapter = :solid_queue` keep that adapter under
# ActiveJob::TestHelper (Rails 7.2+ only overrides explicit adapters when a test
# defines queue_adapter_for_test), so have_enqueued_job and perform_enqueued_jobs
# would never see them. Point them at the shared test adapter by default.
#
# Tag an example `:solid_queue` to exercise the real adapter and tables instead.
module SolidQueueTestAdapter
  def self.jobs
    @jobs ||= begin
      Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/jobs").to_s)
      ActiveJob::Base.descendants.select { |klass| klass._queue_adapter_name == "solid_queue" }
    end
  end
end

RSpec.configure do |config|
  config.around do |example|
    next example.run if example.metadata[:solid_queue]

    jobs = SolidQueueTestAdapter.jobs
    jobs.each { |job| job.enable_test_adapter(ActiveJob::Base.queue_adapter) }
    begin
      example.run
    ensure
      jobs.each(&:disable_test_adapter)
    end
  end
end
