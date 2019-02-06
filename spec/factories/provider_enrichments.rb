# == Schema Information
#
# Table name: provider_enrichment
#
#  id                 :integer          not null
#  provider_code      :text             not null, primary key
#  json_data          :jsonb
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer
#  last_published_at  :datetime
#  status             :integer          default("draft"), not null
#

FactoryBot.define do
  factory :provider_enrichment do
    transient do
      age { nil }
    end

    sequence(:provider_code) { |n| "A#{n}" }
    email { Faker::Internet.email }
    website { Faker::Internet.url }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }
    region_code { ProviderEnrichment.region_codes['Eastern'] }
    train_with_us { Faker::Lorem.sentence.to_s }
    train_with_disability { Faker::Lorem.sentence.to_s }
    created_at { Faker::Date.between 2.days.ago, 1.days.ago }

    after(:build) do |enrichment, evaluator|
      if evaluator.age.present?
        enrichment.created_at = evaluator.age
        enrichment.updated_at = evaluator.age
      end
    end
  end
end
