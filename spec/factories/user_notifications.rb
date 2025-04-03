# frozen_string_literal: true

FactoryBot.define do
  factory :user_notification do
    user
    provider
  end
end
