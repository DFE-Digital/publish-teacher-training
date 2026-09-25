# frozen_string_literal: true

class GeocodeJob < ApplicationJob
  # Solid Queue pilot — rollback by removing this line (global adapter stays Sidekiq).
  self.queue_adapter = :solid_queue
  queue_as :geocoding

  # Solid Queue has no Sidekiq-style auto-retries. Lat/lon overwrite is idempotent,
  # so transient Google/network failures are safe to retry a few times.
  retry_on(
    Timeout::Error,
    Net::OpenTimeout,
    Net::ReadTimeout,
    SocketError,
    Errno::ECONNRESET,
    Errno::ECONNREFUSED,
    Errno::ETIMEDOUT,
    attempts: 5,
    wait: :polynomially_longer,
  )

  def perform(klass, id)
    RequestStore.store[:job_id] = provider_job_id
    RequestStore.store[:job_queue] = queue_name

    record = klass.classify.safe_constantize.find(id)
    GeocoderService.geocode(obj: record) if record
  end
end
