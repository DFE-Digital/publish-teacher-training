module ErrorReporting
  # Use Redis to keep track of errors reported.
  # If more than threshold of any error exists then report
  # Always delete entries older than the window
  #
  # Return true if more than threshold entries exist withiing the window
  class RateLimiter
    def self.report?(key:, threshold:, window: 1.hour)
      redis = RedisClient.cache
      now = Time.zone.now.utc.to_f
      events_key = "error_reporting:events:#{key}"

      count = redis.multi { |r|
        # Add one or more members to a sorted set
        r.zadd(events_key, now, "#{now}-#{SecureRandom.hex(4)}")
        # Remove all members in a sorted set within the given scores.
        r.zremrangebyscore(events_key, "-inf", now - window.to_i)
        # Set a key's time to live in seconds.
        r.expire(events_key, window.to_i + 60)
        # Get the number of members in a sorted set.
        r.zcard(events_key)
      }.last

      count >= threshold
    rescue StandardError
      true
    end
  end
end
