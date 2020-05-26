require "sidekiq/api"

class HeartbeatController < ActionController::API
  def ping
    render body: "PONG"
  end

  def healthcheck
    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq_processes: sidekiq_processes_checks,
    }

    status = checks.values.all? ? :ok : :service_unavailable

    render status: status,
           json: {
             checks: checks,
           }
  end

private

  def database_alive?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end

  def redis_alive?
    Sidekiq.redis_info
    true
  rescue StandardError
    false
  end

  def sidekiq_processes_checks
    stats = Sidekiq::Stats.new
    processes = Sidekiq::ProcessSet.new

    # Iterate over each Sidekiq queue and ensure that there is a process
    # running for it.
    stats.queues.keys.all? do |queue|
      processes.any? { |process| queue.in? process["queues"] }
    end
  rescue StandardError
    false
  end
end
