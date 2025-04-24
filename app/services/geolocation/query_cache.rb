module Geolocation
  class QueryCache
    # Return the cache keys for Geolocation Geocode cache
    # Limit to 100 entries
    def self.entries
      redis = Redis.new(url: ENV.fetch("REDIS_CACHE_URL", "redis://localhost:6379"))
      cursor = 0
      keys = []

      loop do
        cursor, batch = redis.scan(cursor, match: Geolocation::QUERY_CACHE_PATTERN)
        keys.concat(batch)
        break if cursor == "0"
      end

      keys
    end

    def self.count
      redis = Redis.new(url: ENV.fetch("REDIS_CACHE_URL", "redis://localhost:6379"))
      cursor = 0
      count = 0

      loop do
        cursor, keys = redis.scan(cursor, match: Geolocation::QUERY_CACHE_PATTERN)
        count += keys.size
        break count if cursor == "0" || count >= 100
      end
    end

    def self.clear_stats!
      Rails.cache.delete_matched(Geolocation::QUERY_CACHE_STATS_PATTERN)
    end

    def self.clear!
      Rails.cache.delete_matched(Geolocation::QUERY_CACHE_PATTERN)
    end
  end
end
