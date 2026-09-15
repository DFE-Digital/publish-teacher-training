# frozen_string_literal: true

require "rails_helper"
require "erb"
require "yaml"

RSpec.describe "Solid Queue configuration" do
  REQUIRED_QUEUES = %w[
    default
    mailers
    geocoding
    save_statistic
    low_priority
  ].freeze

  def consumed_queues(relative_path)
    yaml = ERB.new(Rails.root.join(relative_path).read).result
    config = YAML.safe_load(yaml, aliases: true)
    section = config[Rails.env] || config["default"] || config.values.first

    Array(section.fetch("workers")).flat_map { |worker| Array(worker.fetch("queues")) }.uniq
  end

  def dispatchers_configured?(relative_path)
    yaml = ERB.new(Rails.root.join(relative_path).read).result
    config = YAML.safe_load(yaml, aliases: true)
    section = config[Rails.env] || config["default"] || config.values.first

    Array(section["dispatchers"]).any?
  end

  it "points SOLID_QUEUE_CONFIG at a queue file" do
    expect(ENV.fetch("SOLID_QUEUE_CONFIG")).to be_in(
      %w[config/queue.yml config/non_production_queue.yml],
    )
  end

  it "consumes every application queue in config/queue.yml" do
    expect(consumed_queues("config/queue.yml")).to include(*REQUIRED_QUEUES)
  end

  it "consumes every application queue in config/non_production_queue.yml" do
    expect(consumed_queues("config/non_production_queue.yml")).to include(*REQUIRED_QUEUES)
  end

  it "defines a dispatcher in both queue configs" do
    expect(dispatchers_configured?("config/queue.yml")).to be(true)
    expect(dispatchers_configured?("config/non_production_queue.yml")).to be(true)
  end

  it "keeps Sidekiq as the application-default Active Job adapter" do
    application_config = Rails.root.join("config/application.rb").read

    expect(application_config).to match(/config\.active_job\.queue_adapter\s*=\s*:sidekiq/)
    expect(application_config).not_to match(/config\.active_job\.queue_adapter\s*=\s*:solid_queue/)
  end
end
