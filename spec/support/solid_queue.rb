# frozen_string_literal: true

# Specs use the test adapter. Tag an example `:solid_queue` to exercise the real
# adapter and tables instead.
#
# This runs as a `before` hook so it lands after ActiveJob::TestHelper's
# before_setup, which would otherwise put every job back on the test adapter.
RSpec.configure do |config|
  jobs = -> { [ActiveJob::Base, *ActiveJob::Base.descendants] }

  config.before(:each, :solid_queue) do
    adapter = ActiveJob::QueueAdapters::SolidQueueAdapter.new
    jobs.call.each { |job| job.enable_test_adapter(adapter) }
  end

  config.after(:each, :solid_queue) do
    jobs.call.each(&:disable_test_adapter)
  end
end
