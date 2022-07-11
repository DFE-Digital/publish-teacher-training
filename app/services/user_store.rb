# frozen_string_literal: true

class UserStore
  class InvalidKeyError < StandardError; end

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  FORM_SECTION_KEYS = %i[
    user
  ].freeze

  def clear_stash(form_store_key)
    set(form_store_key, nil)
  end

  def stash(form_store_key, value)
    set(form_store_key, value)
  end

  def get(key)
    value = redis.get("#{user.id}_#{key}")
    JSON.parse(value) if value.present?
  end

private

  def set(key, values)
    raise(InvalidKeyError) unless FORM_SECTION_KEYS.include?(key)

    redis.set("#{user.id}_#{key}", values.to_json)

    true
  end

  def clear_all
    FORM_SECTION_KEYS.each do |key|
      redis.set("#{user.id}_#{key}", nil)
    end
  end

  def redis
    @redis ||= RedisClient.current
  end
end
