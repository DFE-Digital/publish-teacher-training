FactoryBot.define do
  factory :provider_enrichment do
    sequence(:provider_code) { |n| "A#{n}" }
    json_data {
      { 'email' => Faker::Internet.email,
        'website' => Faker::Internet.url,
        'address1' => Faker::Address.street_address,
        'address2' => Faker::Address.community,
        'address3' => Faker::Address.city,
        'address4' => Faker::Address.state,
        'postcode' => Faker::Address.postcode,
        'train_with_us' => Faker::Lorem.sentence.to_s,
        'train_with_disability' => Faker::Lorem.sentence.to_s }
    }
  end
end
