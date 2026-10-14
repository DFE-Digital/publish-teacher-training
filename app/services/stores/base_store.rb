# frozen_string_literal: true

module Stores
  class BaseStore
    class InvalidKeyError < StandardError; end

    KEY_NAMESPACE = "form_stores"
    EXPIRES_IN = 24.hours

    attr_accessor :identifier_model

    def self.cache
      @cache ||= SolidCache::Store.new
    end

    def initialize(identifier_model)
      @identifier_model = identifier_model
    end

    def store_keys
      raise NotImplementedError
    end

    def clear_stash(store_key)
      cache.delete(identifier(store_key))

      true
    end

    def stash(store_key, value)
      set(store_key, value)
    end

    def get(store_key)
      value = cache.read(identifier(store_key))
      JSON.parse(value) if value.present?
    end

  private

    def identifier_id
      "#{self.class.name}_#{identifier_model.id}"
    end

    def identifier(store_key)
      raise(InvalidKeyError) unless store_keys.include?(store_key)

      "#{KEY_NAMESPACE}/#{identifier_id}_#{store_key}"
    end

    def set(store_key, values)
      cache.write(identifier(store_key), values.to_json, expires_in: EXPIRES_IN)

      true
    end

    def cache
      BaseStore.cache
    end
  end
end
