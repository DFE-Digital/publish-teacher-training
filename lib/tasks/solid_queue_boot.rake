# frozen_string_literal: true

# Review apps (and any env) can bring the solid-queue-worker up before web
# finishes db:setup / migrate / sanitised restore. Solid Queue then caches a
# missing primary key and Sentry floods for the life of the pod.
#
# Waiting only for solid_queue_* is not enough on review: db:setup creates those
# tables quickly, the worker starts, then sanitised restore rewrites the DB
# underneath it. On review we also wait until real sanitised data is present.
#
# schema_ready? can also pass and then lose the tables before solid_queue:start
# finishes registering processes (cancelled restore, overlapping DDL). Those
# failures return to the wait loop instead of raising to Sentry.
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
    # A missing table is cached for the life of this process. db:setup creates
    # the Solid Queue tables after the first poll, so forget that miss or the
    # worker waits out the deadline and restarts even though the schema is ready.
    REQUIRED_TABLES.each do |table|
      connection.schema_cache.clear_data_source_cache!(table)
    end

    tables_ready = REQUIRED_TABLES.all? do |table|
      connection.table_exists?(table) && connection.primary_key(table).present?
    end
    return false unless tables_ready

    if review_environment? && !review_data_present?
      return false
    end

    true
  rescue StandardError => e
    Rails.logger.warn("[solid_queue] waiting for solid_queue schema: #{e.class}: #{e.message}")
    false
  end

  def review_data_present?
    Statistic.reset_column_information
    Statistic.count >= REVIEW_MIN_STATISTIC_ROWS
  end

  def review_environment?
    Settings.environment.name == "review"
  end

  def schema_disappeared_error?(error)
    detail = error.message.to_s
    detail = "#{detail}: #{error.cause.message}" if error.cause

    case error
    when ActiveRecord::UnknownPrimaryKey
      REQUIRED_TABLES.any? { |table| detail.include?(table) }
    when ActiveRecord::StatementInvalid
      undefined_table = error.cause.is_a?(PG::UndefinedTable) ||
        detail.match?(/relation ["'].+["'] does not exist/i)
      undefined_table && detail.include?("solid_queue_")
    else
      false
    end
  end

  def prepare_to_start!
    ActiveRecord::Base.connection_handler.clear_active_connections!
    SolidQueue::Job.reset_column_information
    SolidQueue::Process.reset_column_information
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
    wait_traps = %w[TERM INT].index_with { |signal| Signal.trap(signal) { shutdown_requested = true } }

    restore_wait_traps = lambda do
      wait_traps&.each { |signal, handler| Signal.trap(signal, handler) }
      wait_traps = nil
    end

    install_wait_traps = lambda do
      wait_traps = %w[TERM INT].index_with { |signal| Signal.trap(signal) { shutdown_requested = true } }
    end

    handle_not_ready = lambda do
      if Time.zone.now >= deadline
        # Review workers start during terraform, before db:setup and the
        # sanitised restore. This pod exits so Kubernetes starts another one;
        # an exception here is an expected wait showing up as an unhandled
        # rake error.
        message = "[solid_queue] timed out waiting for Solid Queue schema to be ready"
        if SolidQueueBoot.review_environment?
          Rails.logger.error(message)
          exit 1
        else
          raise message
        end
      end

      Rails.logger.warn("[solid_queue] waiting for Solid Queue schema to be ready")
      Kernel.sleep(poll_interval)
    end

    begin
      loop do
        if shutdown_requested
          Rails.logger.info("[solid_queue] shutdown requested before schema was ready; exiting")
          exit
        end

        unless SolidQueueBoot.schema_ready?
          handle_not_ready.call
          next
        end

        # Solid Queue installs its own signal handlers; drop the wait traps first.
        restore_wait_traps.call
        SolidQueueBoot.prepare_to_start!

        begin
          Rake::Task["solid_queue:start"].reenable
          Rake::Task["solid_queue:start"].invoke
          break
        rescue ActiveRecord::UnknownPrimaryKey, ActiveRecord::StatementInvalid => e
          raise unless SolidQueueBoot.schema_disappeared_error?(e)

          Rails.logger.warn(
            "[solid_queue] schema disappeared while starting Solid Queue (#{e.class}: #{e.message}); waiting again",
          )
          install_wait_traps.call
          handle_not_ready.call
        end
      end
    ensure
      restore_wait_traps.call
    end
  end
end
