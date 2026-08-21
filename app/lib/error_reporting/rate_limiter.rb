module ErrorReporting
  # Count errors in Rails.cache using per-minute counters.
  # Report when the total across the window reaches the threshold.
  #
  # Returns true when the threshold has been reached within the window.
  class RateLimiter
    BUCKET = 1.minute

    def self.report?(key:, threshold:, window: 1.hour)
      now = Time.zone.now
      bucket = now.to_i / BUCKET.to_i
      expires_in = window.to_i + BUCKET.to_i

      current = Rails.cache.increment(cache_key(key, bucket), 1, expires_in: expires_in)
      return true if current.nil?

      minutes = window.to_i / BUCKET.to_i
      total = current + (1...minutes).sum do |offset|
        Rails.cache.read_counter(cache_key(key, bucket - offset)).to_i
      end

      total >= threshold
    rescue StandardError => e
      Rails.logger.tagged("ErrorReporting::RateLimiter") { |l| l.error(e.message) }
      true
    end

    def self.cache_key(key, bucket)
      "error_reporting:#{key}:#{bucket}"
    end
    private_class_method :cache_key
  end
end
