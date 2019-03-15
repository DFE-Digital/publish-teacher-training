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
    vac_status { :full_time_vacancies }

    trait :skips_validate do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :published do
      publish { :published }
    end

    trait :unpublished do
      publish { :unpublished }
    end

    trait :part_time_vacancies do
      vac_status { :part_time_vacancies }
    end

    trait :full_time_vacancies do
      vac_status { :full_time_vacancies }
    end

    trait :both_full_time_and_part_time_vacancies do
      vac_status { :both_full_time_and_part_time_vacancies }
    end

    trait :with_any_vacancy do
      vac_status { %i[both_full_time_and_part_time_vacancies full_time_vacancies part_time_vacancies].sample }
    end

    trait :with_no_vacancies do
      vac_status { :no_vacancies }
    end

    trait :discontinued do
      status { :discontinued }
    end

    trait :running do
      status { :running }
    end

    trait :new do
      status { :new_status }
    end

    trait :suspended do
      status { :suspended }
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

    trait :with_course_study_mode_as_nil do
      association(:course, study_mode: nil)
    end

    trait :with_course_study_mode_as_full_time do
      association(:course, study_mode: "F")
    end

    trait :with_course_study_mode_as_part_time do
      association(:course, study_mode: "P")
    end

    trait :with_course_study_mode_as_full_time_or_part_time do
      association(:course, study_mode: "B")
    end
  end
end
