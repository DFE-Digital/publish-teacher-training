# frozen_string_literal: true

require "rails_helper"
require "erb"
require "yaml"

RSpec.describe "Solid Queue configuration" do
  def required_queues
    %w[
      default
      mailers
      geocoding
      save_statistic
      low_priority
    ]
  end

  def queue_config
    YAML.safe_load(
      ERB.new(Rails.root.join("config/queue.yml").read).result,
      aliases: true,
    )
  end

  def section_for(env)
    queue_config.fetch(env)
  end

  def consumed_queues(env)
    Array(section_for(env).fetch("workers")).flat_map { |worker| Array(worker.fetch("queues")) }.uniq
  end

  it "uses the default Solid Queue config file (no SOLID_QUEUE_CONFIG override)" do
    expect(ENV["SOLID_QUEUE_CONFIG"]).to be_nil.or(eq("config/queue.yml"))
  end

  it "consumes every application queue in production and non-production sections" do
    expect(consumed_queues("production")).to include(*required_queues)
    expect(consumed_queues("review")).to include(*required_queues)
  end

  it "defines env-specific sections for PTT Rails.env values" do
    %w[production development test qa staging sandbox review loadtest rollover].each do |env|
      expect(section_for(env)["workers"]).to be_present
      expect(section_for(env)["dispatchers"]).to be_present
    end
  end

  it "uses slower polling outside production/development" do
    expect(section_for("production").dig("dispatchers", 0, "polling_interval")).to eq(1)
    expect(section_for("review").dig("dispatchers", 0, "polling_interval")).to eq(3)
  end

  it "keeps mailers off the bulk worker in production" do
    production_workers = section_for("production").fetch("workers")
    bulk = production_workers.find { |worker| Array(worker["queues"]).include?("low_priority") }

    expect(bulk["queues"]).not_to include("mailers")
  end

  it "keeps Sidekiq as the application-default Active Job adapter" do
    application_config = Rails.root.join("config/application.rb").read

    expect(application_config).to match(/config\.active_job\.queue_adapter\s*=\s*:sidekiq/)
    expect(application_config).not_to match(/config\.active_job\.queue_adapter\s*=\s*:solid_queue/)
  end

  it "boots Solid Queue via start_when_ready so workers wait for schema" do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    application_tf = Rails.root.join("terraform/aks/application.tf").read

    expect(application_tf).to include("solid_queue:start_when_ready")
    expect(Rake::Task.task_defined?("solid_queue:start_when_ready")).to be(true)
  end

  it "derives Mission Control filter_arguments from filter_parameters" do
    expect(MissionControl::Jobs.filter_arguments).to include("email", "token", "email_address", "headers")
  end

  it "does not draw Turbo Drive routes" do
    expect(Turbo.draw_routes).to be(false)
  end
end
