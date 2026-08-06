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
      provider_school do
        raise ArgumentError, "site is required for :for_site" if site.blank?

        Provider::School.find_by(provider: course.provider, uuid: site.uuid) ||
          association(:provider_school, :for_site, site:, provider: course.provider)
      end

      gias_school do
        provider_school.gias_school
      end
    end
  end
end
