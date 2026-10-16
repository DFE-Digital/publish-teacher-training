# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "legacy_redis_state:reconcile_before_web_boot" do
  before do
    Rake::Task.define_task(:environment) unless Rake::Task.task_defined?(:environment)
    unless Rake::Task.task_defined?("legacy_redis_state:reconcile_before_web_boot")
      load Rails.root.join("lib/tasks/legacy_redis_state.rake")
    end
    Rake::Task["legacy_redis_state:reconcile_before_web_boot"].reenable
    allow(ENV).to receive(:[]).and_call_original
  end

  it "reconciles Redis before the web process starts" do
    allow(ENV).to receive(:[]).with("REDIS_WORKER_URL").and_return("redis://worker")
    allow(LegacyRedisState).to receive(:backfill_database).and_return(feature_flags: 2, site_settings: 1)

    expect { Rake::Task["legacy_redis_state:reconcile_before_web_boot"].invoke }
      .to output(/feature_flags.*2.*site_settings.*1/).to_stdout
    expect(LegacyRedisState).to have_received(:backfill_database)
  end

  it "skips environments without a worker Redis" do
    allow(ENV).to receive(:[]).with("REDIS_WORKER_URL").and_return(nil)
    allow(LegacyRedisState).to receive(:backfill_database)

    expect { Rake::Task["legacy_redis_state:reconcile_before_web_boot"].invoke }
      .to output(/Skipped Redis reconciliation/).to_stdout
    expect(LegacyRedisState).not_to have_received(:backfill_database)
  end

  it "still returns successfully when Redis reconcile is skipped" do
    allow(ENV).to receive(:[]).with("REDIS_WORKER_URL").and_return("redis://worker")
    allow(LegacyRedisState).to receive(:backfill_database).and_return(
      feature_flags: 0,
      site_settings: 0,
      skipped: :redis_unavailable,
    )

    expect { Rake::Task["legacy_redis_state:reconcile_before_web_boot"].invoke }
      .to output(/skipped.*redis_unavailable/).to_stdout
  end
end
