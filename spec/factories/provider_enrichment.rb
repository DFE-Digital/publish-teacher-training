FactoryBot.define do
  factory :provider_enrichment do
    sequence(:provider_code) { |n| "A#{n}" }
    json_data {
      { "Email" => Faker::Internet.email,
        "Website" => Faker::Internet.url,
        "Address1" => Faker::Address.street_address,
        "Address2" => Faker::Address.community,
        "Address3" => Faker::Address.city,
        "Address4" => Faker::Address.state,
        "Postcode" => Faker::Address.postcode,
        "TrainWithUs" => Faker::Lorem.sentence.to_s,
        "TrainWithDisability" => Faker::Lorem.sentence.to_s, }
    }
  end
end
