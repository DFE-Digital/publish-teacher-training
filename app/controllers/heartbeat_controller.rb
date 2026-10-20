# frozen_string_literal: true

class HeartbeatController < ActionController::API
  def ping
    render body: "PONG"
  end

  def healthcheck
    checks = {
      database: database_alive?,
      solid_queue_processes: solid_queue_processes_checks,
    }

    status = checks.values.all? ? :ok : :service_unavailable

    render status:,
           json: {
             checks:,
           }
  end

  def sha
    render json: { sha: ENV.fetch("COMMIT_SHA", nil) }
  end

private

  def database_alive?
    ActiveRecord::Base.connection.execute("SELECT 1") &&
      ActiveRecord::Base.connection.active?
  rescue StandardError
    false
  end

  def solid_queue_processes_checks
    alive_kinds = SolidQueue::Process
      .where(last_heartbeat_at: SolidQueue.process_alive_threshold.ago..)
      .distinct
      .pluck(:kind)

    expected_solid_queue_kinds.all? { |kind| kind.in?(alive_kinds) }
  rescue StandardError
    false
  end

  # Solid Queue only boots a scheduler when this environment has recurring
  # tasks and SOLID_QUEUE_SKIP_RECURRING is not set.
  def expected_solid_queue_kinds
    kinds = %w[Worker Dispatcher]
    kinds << "Scheduler" if recurring_tasks_scheduled?
    kinds
  end

  def recurring_tasks_scheduled?
    Rails.application.config_for(:recurring).any? &&
      !ActiveModel::Type::Boolean.new.cast(ENV["SOLID_QUEUE_SKIP_RECURRING"])
  end
end
