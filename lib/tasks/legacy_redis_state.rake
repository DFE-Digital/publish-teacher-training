# frozen_string_literal: true

namespace :legacy_redis_state do
  desc "Count worker Redis keys by prefix and show GET/SET totals, without values"
  task audit: :environment do
    LegacyRedisState.audit => { prefixes:, commands: }

    prefixes.each { |prefix, count| puts "#{prefix}: #{count}" }
    puts "GET calls: #{commands['get']}, SET calls: #{commands['set']}"
  end

  desc "Copy feature flags and site settings from Redis to the database (roll forward after a rollback)"
  task backfill_database: :environment do
    puts LegacyRedisState.backfill_database
  end

  desc "Copy feature flags and site settings from the database to Redis (before redeploying a release that reads Redis)"
  task sync_to_redis: :environment do
    puts LegacyRedisState.sync_to_redis
  end
end
