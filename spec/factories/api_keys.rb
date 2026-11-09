# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    sequence(:email) { |n| "api-user-#{n}@example.org" }
    sequence(:name) { |n| "Key #{n}" }
    secret { "#{APIKey::SECRET_PREFIX}#{SecureRandom.hex(32)}" }
    key_digest { APIKey.digest(secret) }
    prefix { secret.first(APIKey::DISPLAY_PREFIX_LENGTH) }
  end
end
