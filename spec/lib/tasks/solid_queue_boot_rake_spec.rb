# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "solid_queue:start_when_ready" do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    load Rails.root.join("lib/tasks/solid_queue_boot.rake") unless defined?(SolidQueueBoot)

    Rake::Task["solid_queue:start_when_ready"].reenable
    allow(Rake::Task["solid_queue:start"]).to receive(:invoke)
  end

  it "starts Solid Queue once solid_queue tables have primary keys" do
    connection = ActiveRecord::Base.connection
    SolidQueueBoot::REQUIRED_TABLES.each do |table|
      expect(connection.table_exists?(table)).to be(true)
      expect(connection.primary_key(table)).to be_present
    end

    allow(Settings.environment).to receive(:name).and_return("qa")

    Rake::Task["solid_queue:start_when_ready"].invoke

    expect(Rake::Task["solid_queue:start"]).to have_received(:invoke)
  end

  it "waits while schema is not ready then starts" do
    allow(Settings.environment).to receive(:name).and_return("qa")
    allow(SolidQueueBoot).to receive(:schema_ready?).and_return(false, false, true)
    allow(Kernel).to receive(:sleep)

    Rake::Task["solid_queue:start_when_ready"].invoke

    expect(Kernel).to have_received(:sleep).at_least(:once)
    expect(Rake::Task["solid_queue:start"]).to have_received(:invoke)
  end

  it "forgets a cached missing table before each readiness check" do
    connection = ActiveRecord::Base.connection
    schema_cache = connection.schema_cache
    allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
    allow(connection).to receive(:schema_cache).and_return(schema_cache)
    allow(schema_cache).to receive(:clear_data_source_cache!).and_call_original
    allow(Settings.environment).to receive(:name).and_return("qa")

    SolidQueueBoot.schema_ready?

    SolidQueueBoot::REQUIRED_TABLES.each do |table|
      expect(schema_cache).to have_received(:clear_data_source_cache!).with(table)
    end
  end

  it "exits on review when the schema is still not ready at the deadline" do
    allow(Settings.environment).to receive(:name).and_return("review")
    allow(SolidQueueBoot).to receive(:schema_ready?).and_return(false)
    now = Time.zone.now
    allow(Time.zone).to receive(:now).and_return(now, now + 901)

    expect { Rake::Task["solid_queue:start_when_ready"].invoke }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }

    expect(Rake::Task["solid_queue:start"]).not_to have_received(:invoke)
  end

  it "raises when a non-review schema is still not ready at the deadline" do
    allow(Settings.environment).to receive(:name).and_return("qa")
    allow(SolidQueueBoot).to receive(:schema_ready?).and_return(false)
    now = Time.zone.now
    allow(Time.zone).to receive(:now).and_return(now, now + 901)

    expect { Rake::Task["solid_queue:start_when_ready"].invoke }.to raise_error(
      RuntimeError,
      "[solid_queue] timed out waiting for Solid Queue schema to be ready",
    )
  end

  it "exits cleanly without starting when SIGTERM arrives while waiting" do
    trap_handlers = {}
    allow(Signal).to receive(:trap) do |signal, *_args, &block|
      trap_handlers[signal] = block if block
      "DEFAULT"
    end
    allow(Settings.environment).to receive(:name).and_return("qa")
    allow(SolidQueueBoot).to receive(:schema_ready?).and_return(false)
    allow(Kernel).to receive(:sleep) { trap_handlers.fetch("TERM").call }

    expect { Rake::Task["solid_queue:start_when_ready"].invoke }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }

    expect(Rake::Task["solid_queue:start"]).not_to have_received(:invoke)
    expect(Signal).to have_received(:trap).with("TERM", "DEFAULT")
  end

  describe "SolidQueueBoot.schema_ready?" do
    it "is false in review until sanitised statistic rows exist" do
      allow(Settings.environment).to receive(:name).and_return("review")
      allow(Statistic).to receive(:count).and_return(0)

      expect(SolidQueueBoot.schema_ready?).to be(false)
    end

    it "is true in review once solid_queue PKs and statistic rows exist" do
      allow(Settings.environment).to receive(:name).and_return("review")
      allow(Statistic).to receive(:count).and_return(SolidQueueBoot::REVIEW_MIN_STATISTIC_ROWS)

      expect(SolidQueueBoot.schema_ready?).to be(true)
    end
  end
end
