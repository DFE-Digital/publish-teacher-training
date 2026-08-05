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
          GiasSchool.find_or_create_by!(urn: site.urn) do |school|
            school.name = site.location_name
            school.address1 = site.address1
            school.address2 = site.address2
            school.address3 = site.address3
            school.town = site.town
            school.county = site.address4
            school.postcode = site.postcode
            school.region_code = site.region_code
            school.status_code = GiasSchool.status_codes["open"]
          end
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
    end
  end
end
