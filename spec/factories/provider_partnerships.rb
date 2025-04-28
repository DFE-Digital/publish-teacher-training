# frozen_string_literal: true

FactoryBot.define do
  factory :provider_partnership do
    accredited_provider { association(:accredited_provider) }
    training_provider { association(:provider) }
  end
end
