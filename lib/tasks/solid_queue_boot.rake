# frozen_string_literal: true

# Review apps (and any env) can bring the solid-queue-worker up before web
# finishes db:setup / migrate / sanitised restore. Solid Queue then caches a
# missing primary key and Sentry floods for the life of the pod.
#
# Waiting only for solid_queue_* is not enough on review: db:setup creates those
# tables quickly, the worker starts, then sanitised restore rewrites the DB
# underneath it. On review we also wait until real sanitised data is present.
module SolidQueueBoot
  REQUIRED_TABLES = %w[
    solid_queue_jobs
    solid_queue_processes
    solid_queue_pauses
  ].freeze

  # Sanitised review restores load thousands of statistic rows; empty db:setup does not.
  REVIEW_MIN_STATISTIC_ROWS = Integer(ENV.fetch("SOLID_QUEUE_REVIEW_MIN_STATISTIC_ROWS", "100"))

module_function

  def schema_ready?
    connection = ActiveRecord::Base.connection
    tables_ready = REQUIRED_TABLES.all? do |table|
      connection.table_exists?(table) && connection.primary_key(table).present?
    end
    return false unless tables_ready

    if review_environment? && Statistic.count < REVIEW_MIN_STATISTIC_ROWS
      return false
    end

    true
  rescue StandardError => e
    Rails.logger.warn("[solid_queue] waiting for solid_queue schema: #{e.class}: #{e.message}")
    false
  end

  def review_environment?
    Settings.environment.name == "review"
  end
end

namespace :solid_queue do
  desc "Wait for Solid Queue schema (and review sanitised data), then start"
  task start_when_ready: :environment do
    deadline = Time.zone.now + Integer(ENV.fetch("SOLID_QUEUE_SCHEMA_WAIT_SECONDS", "900"))
    poll_interval = Float(ENV.fetch("SOLID_QUEUE_SCHEMA_POLL_SECONDS", "2"))

    # Pods are routinely replaced (new review deploy, teardown) while still waiting.
    # Without a trap, SIGTERM surfaces as an unhandled SignalException in Sentry.
    shutdown_requested = false
    previous_traps = %w[TERM INT].index_with { |signal| Signal.trap(signal) { shutdown_requested = true } }

    begin
      loop do
        if shutdown_requested
          Rails.logger.info("[solid_queue] shutdown requested before schema was ready; exiting")
          exit
        end

        break if SolidQueueBoot.schema_ready?

        if Time.zone.now >= deadline
          raise "[solid_queue] timed out waiting for Solid Queue schema to be ready"
        end

        Rails.logger.warn("[solid_queue] waiting for Solid Queue schema to be ready")
        Kernel.sleep(poll_interval)
      end
    ensure
      previous_traps.each { |signal, handler| Signal.trap(signal, handler) }
    end

    ActiveRecord::Base.connection_handler.clear_active_connections!
    SolidQueue::Job.reset_column_information
    SolidQueue::Process.reset_column_information

    Rake::Task["solid_queue:start"].invoke
  end
end
