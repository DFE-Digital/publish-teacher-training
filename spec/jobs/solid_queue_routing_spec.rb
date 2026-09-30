# frozen_string_literal: true

require "rails_helper"
require "erb"
require "yaml"

# Card 7 moves PTT-owned jobs onto Solid Queue with per-class adapters while the
# global adapter stays on Sidekiq. Shrink still_on_sidekiq as each tranche lands;
# a new job must opt in to Solid Queue or be listed here deliberately.
RSpec.describe "Solid Queue job routing" do
  let(:still_on_sidekiq) { [] }

  # Framework jobs such as Sentry::SendEventJob also subclass ApplicationJob;
  # they stay on the global adapter until card 8.
  def ptt_jobs
    jobs_dir = Rails.root.join("app/jobs").to_s
    Rails.autoloaders.main.eager_load_dir(jobs_dir)

    ApplicationJob.descendants
      .select { |job| Object.const_source_location(job.name)&.first.to_s.start_with?(jobs_dir) }
      .sort_by(&:name)
  end

  def consumed_queues(env)
    config = YAML.safe_load(ERB.new(Rails.root.join("config/queue.yml").read).result, aliases: true)
    config.fetch(env).fetch("workers").flat_map { |worker| Array(worker.fetch("queues")) }
  end

  it "routes every PTT job to Solid Queue unless it is still listed as on Sidekiq" do
    routing = ptt_jobs.to_h { |job| [job.name, job.queue_adapter_name] }

    on_sidekiq, on_solid_queue = routing.partition { |name, _adapter| still_on_sidekiq.include?(name) }

    expect(on_solid_queue.to_h.values).to all(eq("solid_queue"))
    expect(on_sidekiq.to_h.values).not_to include("solid_queue")
  end

  it "only lists jobs that still exist" do
    expect(still_on_sidekiq - ptt_jobs.map(&:name)).to be_empty
  end

  it "puts every Solid Queue job on a queue the workers consume" do
    solid_queue_jobs = ptt_jobs.select { |job| job.queue_adapter_name == "solid_queue" }

    %w[production review].each do |env|
      solid_queue_jobs.each do |job|
        expect(consumed_queues(env)).to include(job.new.queue_name), "#{job.name} queue not consumed in #{env}"
      end
    end
  end

  it "keeps Sidekiq Cron entries for Solid Queue jobs on queues the workers consume" do
    production_settings = YAML.safe_load(
      ERB.new(Rails.root.join("config/settings/production.yml").read).result,
      aliases: true,
    )

    production_settings.fetch("bg_jobs").each_value do |entry|
      job = entry.fetch("class").safe_constantize
      next unless job.respond_to?(:queue_adapter_name) && job.queue_adapter_name == "solid_queue"

      expect(consumed_queues("production")).to include(entry.fetch("queue")), "#{entry['class']} cron queue not consumed"
    end
  end
end
