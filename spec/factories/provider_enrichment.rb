# == Schema Information
#
# Table name: provider_enrichment
#
#  id                           :integer          not null
#  provider_code                :text             not null, primary key
#  json_data                    :jsonb
#  updated_by_user_id           :integer
#  created_timestamp_utc        :datetime         default(Mon, 01 Jan 0001 00:00:00 UTC +00:00), not null
#  updated_timestamp_utc        :datetime         default(Mon, 01 Jan 0001 00:00:00 UTC +00:00), not null
#  created_by_user_id           :integer
#  last_published_timestamp_utc :datetime
#  status                       :integer          default("draft"), not null
#

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
