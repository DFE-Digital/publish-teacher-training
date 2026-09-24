# frozen_string_literal: true

# Review apps (and any env) can bring the solid-queue-worker up before web
# finishes db:setup / migrate / sanitised restore. Solid Queue then caches a
# missing primary key and Sentry floods for the life of the pod. Wait until the
# schema is actually ready, then start in the same process.
namespace :solid_queue do
  desc "Wait for solid_queue_jobs primary key, then start Solid Queue"
  task start_when_ready: :environment do
    deadline = Time.zone.now + Integer(ENV.fetch("SOLID_QUEUE_SCHEMA_WAIT_SECONDS", "900"))
    poll_interval = Float(ENV.fetch("SOLID_QUEUE_SCHEMA_POLL_SECONDS", "2"))

    loop do
      ready = false
      begin
        connection = ActiveRecord::Base.connection
        ready = connection.table_exists?("solid_queue_jobs") &&
          connection.primary_key("solid_queue_jobs").present?
      rescue StandardError => e
        Rails.logger.warn("[solid_queue] waiting for solid_queue schema: #{e.class}: #{e.message}")
      end

      break if ready

      if Time.zone.now >= deadline
        raise "[solid_queue] timed out waiting for solid_queue_jobs primary key"
      end

      Rails.logger.warn("[solid_queue] waiting for solid_queue_jobs primary key")
      Kernel.sleep(poll_interval)
    end

    # Avoid any column/PK cache from the wait loop; start with a clean read.
    SolidQueue::Job.reset_column_information
    SolidQueue::Process.reset_column_information

    Rake::Task["solid_queue:start"].invoke
  end
end
