# frozen_string_literal: true

require "rails_helper"
require "erb"
require "yaml"

# Solid Queue only runs jobs from queues a worker polls, so a job on an unpolled
# queue sits there silently.
RSpec.describe "Solid Queue job routing" do
  def load_yaml(path)
    YAML.safe_load(ERB.new(Rails.root.join(path).read).result, aliases: true)
  end

  def ptt_jobs
    jobs_dir = Rails.root.join("app/jobs").to_s
    Rails.autoloaders.main.eager_load_dir(jobs_dir)

    ApplicationJob.descendants
      .select { |job| Object.const_source_location(job.name)&.first.to_s.start_with?(jobs_dir) }
      .sort_by(&:name)
  end

  def consumed_queues(env)
    load_yaml("config/queue.yml").fetch(env).fetch("workers").flat_map { |worker| Array(worker.fetch("queues")) }
  end

  it "puts every PTT job on a queue the workers consume" do
    %w[production review].each do |env|
      ptt_jobs.each do |job|
        expect(consumed_queues(env)).to include(job.new.queue_name), "#{job.name} queue not consumed in #{env}"
      end
    end
  end

  it "puts mailer, analytics and cache expiry jobs on queues the workers consume" do
    framework_queues = {
      "Action Mailer" => Rails.application.config.action_mailer.deliver_later_queue_name,
      "DfE Analytics" => DfE::Analytics.config.queue,
      "Solid Cache expiry" => Rails.application.config_for(:cache, env: "production").dig(:store_options, :expiry_queue),
    }

    %w[production review].each do |env|
      framework_queues.each do |name, queue|
        expect(consumed_queues(env)).to include(queue.to_s), "#{name} queue #{queue} not consumed in #{env}"
      end
    end
  end

  it "puts every recurring task on a queue the workers consume" do
    load_yaml("config/recurring.yml").slice("production", "qa", "staging").each do |env, tasks|
      tasks.each do |key, task|
        queue = task.fetch("queue", "solid_queue_recurring")

        expect(consumed_queues(env)).to include(queue), "#{key} queue #{queue} not consumed in #{env}"
      end
    end
  end
end
