# frozen_string_literal: true

namespace :legacy_redis_state do
  desc "Reconcile Redis into the database before a web process accepts traffic"
  task reconcile_before_web_boot: :environment do
    if ENV["REDIS_WORKER_URL"].present?
      puts LegacyRedisState.backfill_database
    else
      puts "Skipped Redis reconciliation: REDIS_WORKER_URL is not configured"
    end
  end

  desc "Count worker Redis keys by prefix and show GET/SET totals, without values"
  task audit: :environment do
    LegacyRedisState.audit => { prefixes:, commands: }

    prefixes.each { |prefix, count| puts "#{prefix}: #{count}" }
    puts "GET calls: #{commands['get']}, SET calls: #{commands['set']}"
  end

  desc "Copy feature flags and site settings from the database to Redis (before redeploying a release that reads Redis)"
  task sync_to_redis: :environment do
    puts LegacyRedisState.sync_to_redis
  end
end
