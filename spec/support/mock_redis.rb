# frozen_string_literal: true

require "mock_redis"

RSpec.configure do |config|
  config.before do
    mock_redis = MockRedis.new
    allow(Redis).to receive(:new).and_return(mock_redis)

    RedisClient.current.flushdb
  end
end
