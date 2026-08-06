# frozen_string_literal: true

FactoryBot.define do
  factory :provider_school, class: "Provider::School" do
    provider
    gias_school
    # Walks "A", "B", ... "Z", "AA", ... via String#next
    sequence(:site_code, "A")
    uuid { SecureRandom.uuid }

    transient do
      site { nil }
    end

    trait :main_site do
      site_code { Provider::School::MAIN_SITE_CODE }
    end

    trait :for_site do
      provider do
        raise ArgumentError, "site is required for :for_site" if site.blank?

        site.provider
      end

      gias_school do
        raise ArgumentError, "site is required for :for_site" if site.blank?

        if site.urn.present?
          school = GiasSchool.find_or_initialize_by(urn: site.urn)
          school.assign_attributes(
            name: site.location_name,
            address1: site.address1,
            address2: site.address2,
            address3: site.address3,
            town: site.town,
            county: site.address4,
            postcode: site.postcode,
            region_code: site.region_code,
          )
          school.status_code ||= GiasSchool.status_codes["open"]
          school.save!
          school
        else
          create(
            :gias_school,
            name: site.location_name,
            address1: site.address1,
            address2: site.address2,
            address3: site.address3,
            town: site.town,
            county: site.address4,
            postcode: site.postcode,
            region_code: site.region_code,
          )
        end
      end

      site_code { site.code }
      uuid { site.uuid }

      initialize_with do
        Provider::School.find_or_initialize_by(provider:, gias_school:, site_code:)
      end
    end
  end
end
