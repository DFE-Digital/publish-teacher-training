# == Schema Information
#
# Table name: provider
#
#  accrediting_provider             :text
#  accrediting_provider_enrichments :jsonb
#  address1                         :text
#  address2                         :text
#  address3                         :text
#  address4                         :text
#  changed_at                       :datetime         not null
#  contact_name                     :text
#  created_at                       :datetime         not null
#  discarded_at                     :datetime
#  email                            :text
#  id                               :integer          not null, primary key
#  latitude                         :float
#  longitude                        :float
#  postcode                         :text
#  provider_code                    :text
#  provider_name                    :text
#  provider_type                    :text
#  recruitment_cycle_id             :integer          not null
#  region_code                      :integer
#  scheme_member                    :text
#  telephone                        :text
#  train_with_disability            :text
#  train_with_us                    :text
#  updated_at                       :datetime         not null
#  website                          :text
#  year_code                        :text
#
# Indexes
#
#  index_provider_on_changed_at                              (changed_at) UNIQUE
#  index_provider_on_discarded_at                            (discarded_at)
#  index_provider_on_latitude_and_longitude                  (latitude,longitude)
#  index_provider_on_recruitment_cycle_id_and_provider_code  (recruitment_cycle_id,provider_code) UNIQUE
#

FactoryBot.define do
  factory :provider do
    provider_name { "ACME SCITT" + rand(1000000).to_s }

    sequence(:provider_code) do |n|
      "A#{(Provider.where("provider_code like 'A%'").pluck(:provider_code).map { |e| e.slice(1..-1) }.select { |e| e.match(/^\d+$/) }.map(&:to_i).max || 0) + n}"
    end

    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }
    contact_name { Faker::Name.name }
    email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
    website { Faker::Internet.url }
    accrediting_provider { "N" }
    region_code { "london" }
    organisations { [create(:organisation, :with_user)] }
    association :recruitment_cycle, strategy: :find_or_create

    train_with_us { Faker::Lorem.sentence.to_s }
    train_with_disability { Faker::Lorem.sentence.to_s }
    accrediting_provider_enrichments { nil }

    trait :accredited_body do
      accrediting_provider { "Y" }
    end

    transient do
      changed_at           { nil }
      skip_associated_data { false }
    end

    after(:create) do |provider, evaluator|
      # Strangely, changed_at doesn't get set if we don't do this, even though
      # updated_at does. Maybe this is because we've added changed_at to
      # timestamp_attributes_for_update but FactoryBot doesn't actually
      # recognise it.
      if evaluator.changed_at.present?
        provider.update changed_at: evaluator.changed_at
      end
    end

    trait :next_recruitment_cycle do
      recruitment_cycle { find_or_create :recruitment_cycle, :next }
    end

    trait :discarded do
      discarded_at { Time.now.utc }
    end

    trait :previous_recruitment_cycle do
      recruitment_cycle { find_or_create :recruitment_cycle, :previous }
    end

    trait :published_scitt do
      transient do
        identifier { "published_scitt" }
      end

      provider_name { "#{identifier} provider name" }
    end
  end
end
