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
#  last_published_at    :datetime
#  changed_at           :datetime         not null
#  opted_in             :boolean          default(FALSE)
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
    contact_name { Faker::Name.name }
    email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
    accrediting_provider { 'N' }
    region_code { 'london' }
    organisations { build_list :organisation, 1 }

    transient do
      changed_at           { nil }
      skip_associated_data { false }
      site_count           { 1 }
      sites                { build_list :site, site_count, provider: nil }
      course_count         { 0 }
      enrichments          { [build(:provider_enrichment)] }
    end

    after(:create) do |provider, evaluator|
      provider.sites << evaluator.sites

      # Add the enrichments to the provider. Normally setting provider_code
      # would be the model's concern, but as we're still a read-only app we'll
      # have to do that here.
      provider.enrichments << evaluator.enrichments.each do |enrichment|
        enrichment.provider_code = provider.provider_code
      end

      # Strangely, changed_at doesn't get set if we don't do this, even though
      # updated_at does. Maybe this is because we've added changed_at to
      # timestamp_attributes_for_update but FactoryBot doesn't actually
      # recognise it.
      if evaluator.changed_at.present?
        provider.update changed_at: evaluator.changed_at
      end

      if provider.ucas_preferences.nil?
        provider.ucas_preferences = create(:ucas_preferences, provider: provider)
      end
    end
  end
end
