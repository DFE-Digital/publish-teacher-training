# frozen_string_literal: true

FactoryBot.define do
  factory :user_notification do
    association :user
    association :provider
  end
end
