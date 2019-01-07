FactoryBot.define do
  factory :provider do
    provider_name { 'ACME SCITT' + rand(1000000).to_s }
    sequence(:provider_code) { |n| "A#{n}" }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }

    transient do
      site_count { 1 }
      course_count { 2 }
      enrichment_count { 1 }
    end

    after(:create) do |provider, evaluator|
      create_list(:course, evaluator.course_count, provider: provider)
      create_list(:site, evaluator.site_count, provider: provider)
      create_list(:provider_enrichment, evaluator.enrichment_count, provider: provider)
    end
  end
end
