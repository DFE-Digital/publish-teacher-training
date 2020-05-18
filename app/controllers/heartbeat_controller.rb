require "sidekiq/api"

class HeartbeatController < ActionController::API
  def ping
    render body: "PONG"
  end

  def healthcheck
    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
      sidekiq_queue: sidekiq_queue_healthy?,
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

  def sidekiq_alive?
    ps = Sidekiq::ProcessSet.new
    !ps.size.zero?
  rescue StandardError
    false
  end

  def sidekiq_queue_healthy?
    dead = Sidekiq::DeadSet.new
    retries = Sidekiq::RetrySet.new
    dead.size.zero? && retries.size.zero?
  rescue StandardError
    false
  end
end
