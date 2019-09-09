# == Schema Information
#
# Table name: provider_enrichment
#
#  id                 :integer          not null, primary key
#  provider_code      :text             not null
#  json_data          :jsonb
#  updated_by_user_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer          not null
#  last_published_at  :datetime
#  status             :integer          default("draft"), not null
#  provider_id        :integer          not null
#


FactoryBot.define do
  factory :provider_enrichment do
    transient do
      age { nil }
    end

    provider
    provider_code { provider.provider_code }

    status { :draft }

    email { Faker::Internet.email }
    website { Faker::Internet.url }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }
    telephone { '01234 123 123 ext 123' }
    region_code { ProviderEnrichment.region_codes.values.sample }
    train_with_us { Faker::Lorem.sentence.to_s }
    train_with_disability { Faker::Lorem.sentence.to_s }
    accrediting_provider_enrichments { nil }

    updated_by_user_id { create(:user).id }
    created_by_user_id { create(:user).id }


    after(:build) do |enrichment, evaluator|
      if evaluator.age.present?
        enrichment.created_at = evaluator.age
        enrichment.updated_at = evaluator.age
      end
    end

    trait :published do
      status { :published }
      last_published_at { 5.days.ago }
    end

    trait :initial_draft do
      status { :draft }
      last_published_at { nil }
    end

    trait :subsequent_draft do
      status { :draft }
      last_published_at { 5.days.ago }
    end

    trait :without_content do
      email { nil }
      website { nil }
      telephone { nil }

      address1 { nil }
      address3 { nil }
      address4 { nil }
      postcode { nil }
      train_with_us { nil }
      train_with_disability { nil }
    end
  end
end
