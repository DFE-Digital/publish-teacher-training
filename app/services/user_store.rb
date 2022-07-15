# frozen_string_literal: true

class UserStore
  class InvalidKeyError < StandardError; end

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  FORM_STORE_KEYS = %i[
    user
  ].freeze

  def clear_stash(form_store_key)
    set(form_store_key, nil)
  end

  def stash(form_store_key, value)
    set(form_store_key, value)
  end

  def get(form_store_key)
    value = redis.get("#{user.id}_#{form_store_key}")
    JSON.parse(value) if value.present?
  end

private

  def set(form_store_key, values)
    raise(InvalidKeyError) unless FORM_STORE_KEYS.include?(form_store_key)

    redis.set("#{user.id}_#{form_store_key}", values.to_json)

    true
  end

  def redis
    @redis ||= RedisClient.current
  end
end
