# frozen_string_literal: true

# Sidekiq Cron records an occurrence before it calls Active Job. If enqueueing
# directly onto Solid Queue then fails, Sidekiq Cron considers the occurrence
# complete and does not try it again. This native Sidekiq worker keeps the
# handoff inside Sidekiq's retry lifecycle instead.
class SolidQueueCronHandoffWorker
  include Sidekiq::Job

  # Five retries span under ten minutes. Sidekiq's default of 25 spans about
  # three weeks, long enough for a daily run to land days late or overlap the
  # next occurrence.
  sidekiq_options retry: 5

  # Runs at Sidekiq startup, so an entry that cannot be wrapped is left as it
  # was rather than stopping Sidekiq from booting.
  def self.wrap(cron_jobs)
    cron_jobs.transform_values do |job_attributes|
      job_attributes = job_attributes.to_h.deep_dup
      target_class_name = job_attributes[:class].to_s
      target_class = target_class_name.safe_constantize

      next job_attributes unless target_class.respond_to?(:queue_adapter_name) &&
        target_class.queue_adapter_name == "solid_queue"

      target_arguments = Array.wrap(job_attributes.fetch(:args, []))
      target_queue = (job_attributes[:queue] || target_class.new.queue_name).to_s

      job_attributes.merge(
        class: name,
        queue: target_queue,
        args: [target_class_name, target_arguments, target_queue],
      )
    end
  end

  def perform(target_class_name, target_arguments, target_queue)
    target_class_name.constantize
      .set(queue: target_queue)
      .perform_later(*target_arguments)
  end
end
