# == Schema Information
#
# Table name: provider
#
#  id                   :integer          not null, primary key
#  address4             :text
#  provider_name        :text
#  scheme_member        :text
#  contact_name         :text
#  year_code            :text
#  provider_code        :text
#  provider_type        :text
#  postcode             :text
#  scitt                :text
#  url                  :text
#  address1             :text
#  address2             :text
#  address3             :text
#  email                :text
#  telephone            :text
#  region_code          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  accrediting_provider :text
#

FactoryBot.define do
  factory :provider do
    provider_name { 'ACME SCITT' + rand(1000000).to_s }
    sequence(:provider_code) { |n| "A#{n}" }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }
    accrediting_provider { 'N' }

    transient do
      age          { nil }
      site_count   { 1 }
      sites        { build_list :site, site_count, provider: nil, age: age }
      course_count { 2 }
      enrichments  { [build(:provider_enrichment)] }
    end

    after(:build) do |provider, evaluator|
      if evaluator.age.present?
        provider.created_at = evaluator.age
        provider.updated_at = evaluator.age
      end
    end

    after(:create) do |provider, evaluator|
      create_list(:course, evaluator.course_count, provider: provider)

      provider.sites << evaluator.sites

      # Add the enrichments to the provider. Normally setting provider_code
      # would be the model's concern, but as we're still a read-only app we'll
      # have to do that here.
      provider.enrichments << evaluator.enrichments.each do |enrichment|
        enrichment.provider_code ||= provider.provider_code
      end
    end
  end
end
