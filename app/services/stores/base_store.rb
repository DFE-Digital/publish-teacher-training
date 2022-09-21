# frozen_string_literal: true

module Stores
  class BaseStore
    class InvalidKeyError < StandardError; end

    attr_accessor :identifier_model

    def initialize(identifier_model)
      @identifier_model = identifier_model
    end

    def store_keys
      raise NotImplementedError
    end

    def clear_stash(store_key)
      set(store_key, nil)
    end

    def stash(store_key, value)
      set(store_key, value)
    end

    def get(store_key)
      value = redis.get(identifier(store_key))
      JSON.parse(value) if value.present?
    end

  private

    def identifier_id
      raise NotImplementedError
    end

    def identifier(store_key)
      raise(InvalidKeyError) unless store_keys.include?(store_key)

      "#{identifier_id}_#{store_key}"
    end

    def set(store_key, values)
      redis.set(identifier(store_key), values.to_json)

      true
    end

    def redis
      @redis ||= RedisClient.current
    end
  end
end
