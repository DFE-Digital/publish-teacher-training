# frozen_string_literal: true

FactoryBot.define do
  sequence(:course_school_provider_site_code, "A")

  factory :course_school, class: "Course::School" do
    course
    gias_school

    transient do
      site { nil }
      site_code { generate(:course_school_provider_site_code) }
    end

    provider_school do
      Provider::School.find_by(provider: course.provider, gias_school:, site_code:) ||
        association(:provider_school, provider: course.provider, gias_school:, site_code:)
    end

    trait :main_site do
      site_code { Provider::School::MAIN_SITE_CODE }
    end

    trait :for_site do
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

      provider_school do
        raise ArgumentError, "site is required for :for_site" if site.blank?

        Provider::School.find_by(provider: course.provider, gias_school:, site_code: site.code) ||
          association(:provider_school, :for_site, site:, provider: course.provider, gias_school:)
      end
    end
  end
end
