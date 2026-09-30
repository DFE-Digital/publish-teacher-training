# frozen_string_literal: true

# Sidekiq Cron records an occurrence before it calls Active Job. If enqueueing
# directly onto Solid Queue then fails, Sidekiq Cron considers the occurrence
# complete and does not try it again. This native Sidekiq worker keeps the
# handoff inside Sidekiq's retry lifecycle instead.
class SolidQueueCronHandoffWorker
  include Sidekiq::Job

  def self.wrap(cron_jobs)
    cron_jobs.transform_values do |job_attributes|
      job_attributes = job_attributes.to_h.deep_dup
      target_class_name = job_attributes.fetch(:class).to_s
      target_class = target_class_name.constantize

      next job_attributes unless target_class.respond_to?(:queue_adapter_name) &&
        target_class.queue_adapter_name == "solid_queue"

      target_arguments = Array.wrap(job_attributes.fetch(:args, []))
      target_queue = job_attributes.fetch(:queue).to_s

      job_attributes.merge(
        class: name,
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
