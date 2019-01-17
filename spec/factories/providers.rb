# == Schema Information
#
# Table name: provider
#
#  id            :integer          not null, primary key
#  address4      :text
#  provider_name :text
#  scheme_member :text
#  contact_name  :text
#  year_code     :text
#  provider_code :text
#  provider_type :text
#  postcode      :text
#  scitt         :text
#  url           :text
#  address1      :text
#  address2      :text
#  address3      :text
#  email         :text
#  telephone     :text
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

    transient do
      site_count { 1 }
      course_count { 2 }
      enrichments { build_list(:provider_enrichment, 1) }
    end

    after(:create) do |provider, evaluator|
      create_list(:course, evaluator.course_count, provider: provider)
      create_list(:site, evaluator.site_count, provider: provider)
      # Add the enrichments to the provider. Normally setting provider_code
      # would be the model's concern, but as we're still a read-only app we'll
      # have to do that here.
      provider.enrichments << evaluator.enrichments.each do |enrichment|
        enrichment.provider_code ||= provider.provider_code
      end
    end
  end
end
