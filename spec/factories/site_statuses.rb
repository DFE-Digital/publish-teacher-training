# == Schema Information
#
# Table name: course_site
#
#  id                         :integer          not null, primary key
#  applications_accepted_from :date
#  course_id                  :integer
#  publish                    :text
#  site_id                    :integer
#  status                     :text
#  vac_status                 :text
#

FactoryBot.define do
  factory :site_status do
    association(:course)
    association(:site)
    publish { 'N' }
    vac_status { '' }

    trait :published do
      publish { 'Y' }
    end

    trait :unpublished do
      publish { 'N' }
    end

    trait :part_time_vacancies do
      vac_status { 'P' }
    end

    trait :full_time_vacancies do
      vac_status { 'F' }
    end

    trait :both_full_time_and_part_time_vacancies do
      vac_status { 'B' }
    end

    trait :with_any_vacancy do
      vac_status { %w[P F B].sample }
    end

    trait :discontinued do
      status { 'D' }
    end

    trait :running do
      status { 'R' }
    end

    trait :new do
      status { 'N' }
    end

    trait :suspended do
      status { 'S' }
    end

    trait :applications_being_accepted_now do
      applications_accepted_from { Faker::Date.between 2.days.ago, 0.days.ago }
    end

    trait :applications_being_accepted_in_future do
      applications_accepted_from { Faker::Date.forward 90 }
    end

    trait :findable do
      running
      published
    end

    trait :findable_and_with_any_vacancy do
      findable
      with_any_vacancy
    end
  end
end
